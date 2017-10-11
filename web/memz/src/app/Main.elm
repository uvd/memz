port module Main exposing (..)

import Date exposing (..)
import Debug exposing (log)
import Dict exposing (get)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (Error)
import HttpBuilder exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Event, EventResponse, Msg)
import Model exposing (..)
import Navigation
import Pages.CreateEventPage as CreateEventPage
import Pages.EventPage as EventPage
import Pages.HomePage as HomePage
import UrlParser exposing ((</>), Parser, int, map, oneOf, parseHash, s, string)


type alias LocalStorageRecord =
    ( String, String )


incrementCurrentStep : Step -> Step
incrementCurrentStep step =
    case step of
        Model.OwnerStep ->
            Model.NameStep

        Model.NameStep ->
            Model.EndDateTimeStep

        s ->
            s


view : Model -> Html Msg
view model =
    case model.route of
        Public HomePageRoute ->
            HomePage.view

        Public CreateEventRoute ->
            CreateEventPage.view model

        Private (EventRoute id slug) ->
            EventPage.view


updateNewEvent : (NewEvent -> NewEvent) -> Model -> Model
updateNewEvent update m =
    let
        updatedNewEvent =
            update m.newEvent
    in
        { m | newEvent = updatedNewEvent }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Messages.Name n ->
            ( updateNewEvent (\x -> { x | name = n }) model, Cmd.none )

        Messages.Owner o ->
            ( updateNewEvent (\x -> { x | owner = o }) model, Cmd.none )

        Messages.EndDateTime d ->
            ( updateNewEvent (\x -> { x | endDateTime = d }) model, Cmd.none )

        Messages.IncrementStep ->
            ( updateNewEvent (\x -> { x | step = incrementCurrentStep x.step }) model, Cmd.none )

        Messages.CreateEvent ->
            ( model, postCreateEvent (bodyEncoder model.newEvent) )

        Messages.CreateEventResponse (Result.Ok ( header, { id, slug } )) ->
            let
                eventUrl =
                    "/#/event/" ++ (toString id) ++ "/" ++ slug
            in
                ( { model | token = Just header }, Cmd.batch [ setLocalStorageItem ( "authToken", header ), Navigation.newUrl <| eventUrl ] )

        Messages.CreateEventResponse (Result.Err err) ->
            case err of
                Http.BadStatus badResponse ->
                    let
                        decodedResponse =
                            Decode.decodeString errorResponseDecoder badResponse.body

                        updatedModel =
                            { model | newEvent = initialNewEvent }
                    in
                        case decodedResponse of
                            Ok serverErrors ->
                                ( updateNewEvent (\x -> { x | errors = serverErrors }) updatedModel, Cmd.none )

                            Err _ ->
                                ( updatedModel, Cmd.none )

                Http.BadPayload err _ ->
                    Debug.log ("BAD PAYLOAD ERROR" ++ err)
                        ( model, Cmd.none )

                _ ->
                    Debug.log "ERROR"
                        ( model, Cmd.none )

        Messages.GetEventResponse (Result.Ok response) ->
            ( { model | event = Just response }, Cmd.none )

        Messages.GetEventResponse (Result.Err err) ->
            --@TODO
            ( model, Cmd.none )

        Messages.UrlChange location ->
            onLocationChange model location

        Messages.LocalStorageResponse ( "authToken", value ) ->
            ( { model | token = value }
            , case value of
                Just token ->
                    commandForRoute model.route value

                Nothing ->
                    Debug.log "Redirect" <| Navigation.newUrl "/"
            )

        Messages.LocalStorageResponse _ ->
            ( model, Cmd.none )


commandForRoute : Route -> Maybe String -> Cmd Msg
commandForRoute route token =
    case route of
        Private (EventRoute id slug) ->
            case token of
                Just token ->
                    getRequestForEvent id slug token

                Nothing ->
                    Cmd.none

        _ ->
            Cmd.none


getRequestForEvent : Int -> String -> String -> Cmd Msg
getRequestForEvent id slug token =
    let
        url =
            "http://localhost:4000/v1/event/" ++ toString id ++ "/" ++ slug
    in
        HttpBuilder.get url
            |> withHeader "Authorization" token
            |> withExpect (Http.expectJson responseDecoder)
            |> send Messages.GetEventResponse


getRoute : Navigation.Location -> Route
getRoute location =
    case parseHash route location of
        Just route ->
            route

        _ ->
            Public HomePageRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ UrlParser.map (\id slug -> Private (EventRoute id slug)) (UrlParser.s "event" </> int </> string)
        , UrlParser.map (Public CreateEventRoute) (UrlParser.s "create-event")
        ]


onLocationChange : Model -> Navigation.Location -> ( Model, Cmd Msg )
onLocationChange model location =
    let
        newRoute =
            getRoute location
    in
        case ( newRoute, model.token ) of
            ( Public r, _ ) ->
                ( { model | route = newRoute }, commandForRoute newRoute model.token )

            ( Private r, Just token ) ->
                ( { model | route = newRoute }, commandForRoute newRoute model.token )

            ( Private r, Nothing ) ->
                ( { model | route = newRoute }, commandForAuthToken )


commandForAuthToken : Cmd Msg
commandForAuthToken =
    getLocalStorageItem "authToken"


postCreateEvent : String -> Cmd Msg
postCreateEvent encodedData =
    Http.send Messages.CreateEventResponse <|
        getCreateEventRequest "http://localhost:4000/v1/events" (Http.stringBody "application/json" encodedData)


getCreateEventRequest : String -> Http.Body -> Http.Request EventResponse
getCreateEventRequest url body =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect =
            Http.expectStringResponse
                (\r ->
                    let
                        header =
                            extractHeader "authorization" r

                        body =
                            Decode.decodeString responseDecoder r.body
                    in
                        case ( header, body ) of
                            ( Just header, Ok body ) ->
                                Ok ( header, body )

                            ( Just _, Err error ) ->
                                Err error

                            ( Nothing, Ok _ ) ->
                                Err "No authorization header"

                            ( Nothing, Err error ) ->
                                Err ("No authorization header, and " ++ error)
                )
        , timeout = Nothing
        , withCredentials = False
        }


bodyEncoder : { a | name : String, owner : String, endDateTime : String } -> String
bodyEncoder data =
    let
        encodedValue =
            Encode.object
                [ ( "event"
                  , Encode.object
                        [ ( "name", Encode.string data.name )
                        , ( "owner", Encode.string data.owner )
                        , ( "end_date", Encode.string data.endDateTime )
                        ]
                  )
                ]
    in
        Encode.encode 0 encodedValue


errorResponseDecoder : Decode.Decoder (List ServerError)
errorResponseDecoder =
    Decode.at [ "errors" ] (Decode.keyValuePairs (Decode.list Decode.string))


responseDecoder : Decode.Decoder Event
responseDecoder =
    Decode.at [ "data" ]
        (Decode.map5
            Event
            (Decode.at [ "id" ] Decode.int)
            (Decode.at [ "name" ] Decode.string)
            (Decode.at [ "owner" ] Decode.string)
            (Decode.at [ "end_date" ] Decode.string)
            (Decode.at [ "slug" ] Decode.string)
        )


extractHeader : String -> Http.Response a -> Maybe String
extractHeader name response =
    Dict.get name response.headers


port getLocalStorageItem : String -> Cmd msg


port getLocalStorageItemResponse : (( String, Maybe String ) -> msg) -> Sub msg


port setLocalStorageItem : LocalStorageRecord -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    getLocalStorageItemResponse Messages.LocalStorageResponse


main : Program Never Model Msg
main =
    Navigation.program Messages.UrlChange
        { init = onLocationChange Model.initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
