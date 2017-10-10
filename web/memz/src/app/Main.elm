port module Main exposing (..)

import Date exposing (..)
import Debug exposing (log)
import Dict exposing (get)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Event, EventResponse, Msg)
import Model exposing (Model, NewEvent, Route, ServerError, Step, initialModel, initialNewEvent)
import Navigation
import Pages.CreateEventPage as CreateEventPage
import Pages.HomePage as HomePage


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
        Model.HomePageRoute ->
            HomePage.view

        Model.CreateEventRoute ->
            CreateEventPage.view model


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

        Messages.CreateEventResponse (Result.Ok ( header, _ )) ->
            ( { model | token = Just header }, setLocalStorageItem ( "authToken", header ) )

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

        Messages.UrlChange location ->
            ( { model | route = getRoute location }, Cmd.none )


getRoute : Navigation.Location -> Route
getRoute location =
    case location.hash of
        "#create-event" ->
            Model.CreateEventRoute

        _ ->
            Model.HomePageRoute


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { initialModel | route = getRoute location }
    , Cmd.none
    )


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


port setLocalStorageItem : LocalStorageRecord -> Cmd msg


main : Program Never Model Msg
main =
    Navigation.program Messages.UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
