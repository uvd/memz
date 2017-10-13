port module Main exposing (..)

import Data.Event exposing (..)
import Debug exposing (log)
import Dict exposing (get)
import FileReader exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (Error)
import HttpBuilder exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (EventResponse, Msg)
import Model exposing (..)
import Navigation
import Pages.CreateEventPage as CreateEventPage
import Pages.EventPage as EventPage
import Pages.HomePage as HomePage
import Phoenix.Channel
import Phoenix.Socket
import Route exposing (..)
import Task
import Regex


type alias LocalStorageRecord =
    ( String, String )


view : Model -> Html Msg
view model =
    case model.route of
        Public HomePageRoute ->
            HomePage.view

        Public CreateEventRoute ->
            CreateEventPage.view model

        Private (EventRoute id slug) ->
            EventPage.view model


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
            ( updateNewEvent (\x -> { x | step = CreateEventPage.incrementCurrentStep x.step }) model, Cmd.none )

        Messages.CreateEvent ->
            ( model, postCreateEvent model.baseUrl (bodyEncoder model.newEvent) )

        Messages.CreateEventResponse (Result.Ok ( header, { id, slug } )) ->
            let
                eventUrl =
                    "/#/event/" ++ toString id ++ "/" ++ slug
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
            let
                channelId =
                    "event:" ++ toString response.id

                payload =
                    Encode.object [ ( "guardian_token", stripBearer >> Encode.string <| (Maybe.withDefault "" model.token) ) ]

                channel =
                    Phoenix.Channel.init channelId
                        |> Phoenix.Channel.withPayload payload
                        |> Phoenix.Channel.onJoin Messages.EventChannelJoined

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket

                currentEvent =
                    model.currentEvent

                updatedEvent =
                    { currentEvent | event = Just response }
            in
                ( { model | currentEvent = updatedEvent, phxSocket = phxSocket }, Cmd.map Messages.PhoenixMsg phxCmd )

        Messages.GetEventResponse (Result.Err err) ->
            Debug.log "Error getting event"
                ( model, Cmd.none )

        Messages.UrlChange location ->
            onLocationChange model location

        Messages.LocalStorageResponse ( "authToken", value ) ->
            ( { model | token = value }
            , case value of
                Just token ->
                    commandForRoute model.route value model.baseUrl

                Nothing ->
                    Debug.log "Redirect" <| Navigation.newUrl "/"
            )

        Messages.LocalStorageResponse _ ->
            ( model, Cmd.none )

        Messages.PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map Messages.PhoenixMsg phxCmd
                )

        Messages.EventChannelJoined jsonValue ->
            let
                photos =
                    Result.withDefault [] <| Decode.decodeValue (Decode.list photoDecoder) jsonValue
            in
                case model.currentEvent.event of
                    Nothing ->
                        ( model, Cmd.none )

                    Just event ->
                        let
                            currentEvent =
                                model.currentEvent

                            updatedEvent =
                                { currentEvent | photos = photos }
                        in
                            ( { model | currentEvent = updatedEvent }, Cmd.none )

        Messages.PhotoSelected nativeFiles ->
            let
                task =
                    List.map (.blob >> FileReader.readAsDataUrl) nativeFiles
                        |> Task.sequence

                currentEvent =
                    model.currentEvent

                updatedCurrentEvent =
                    { currentEvent | status = Uploading }
            in
                ( { model | currentEvent = updatedCurrentEvent }, Task.attempt Messages.UploadPhoto task )

        Messages.UploadPhoto (Err err) ->
            Debug.log "Error encoding photo" ( model, Cmd.none )

        Messages.UploadPhoto (Ok values) ->
            case ( model.currentEvent.event, model.token ) of
                ( Just event, Just token ) ->
                    let
                        { id, slug } =
                            event

                        firstPhoto =
                            (List.head values)

                    in
                        case firstPhoto of
                            Nothing ->
                                ( model, Cmd.none )

                            Just value ->
                                case Decode.decodeValue Decode.string value of
                                    Ok photo ->
                                        ( model, postPhoto photo id slug model.baseUrl token )
                                    Err err ->
                                        (model, Cmd.none)

                _ ->
                    ( model, Cmd.none )

        Messages.PostPhotoResponse (Err err) ->
            let
                currentEvent =
                    model.currentEvent

                updatedCurrentEvent =
                    { currentEvent | status = Idle }
            in
                Debug.log "Error uplodaing photo" ( { model | currentEvent = updatedCurrentEvent }, Cmd.none )

        Messages.PostPhotoResponse (Ok _) ->
            let
                currentEvent =
                    model.currentEvent

                updatedCurrentEvent =
                    { currentEvent | status = Idle }
            in
                ( { model | currentEvent = updatedCurrentEvent }, Cmd.none )


commandForRoute : Route -> Maybe String -> String -> Cmd Msg
commandForRoute route token baseUrl =
    case route of
        Private (EventRoute id slug) ->
            case token of
                Just token ->
                    getRequestForEvent id slug token baseUrl

                Nothing ->
                    Cmd.none

        _ ->
            Cmd.none


stripBearer : String -> String
stripBearer fullToken =
    let
        regex =
            (Regex.regex " ")

        splitToken =
            Regex.split (Regex.AtMost 1) regex fullToken
    in
        case splitToken of
            [ _, token ] ->
                token

            _ ->
                ""


postPhoto : String -> Int -> String -> String -> String -> Cmd Msg
postPhoto encodedPhoto id slug baseUrl token =
    let
        url =
            baseUrl ++ "/v1/events/" ++ toString id ++ "/" ++ slug ++ "/images"
    in
        HttpBuilder.post url
            |> withBody (imageEncoder {photo = encodedPhoto} |> Http.jsonBody)
            |> withHeader "Authorization" token
            |> withExpect (Http.expectStringResponse (always (Ok ())))
            |> send Messages.PostPhotoResponse


getRequestForEvent : Int -> String -> String -> String -> Cmd Msg
getRequestForEvent id slug token baseUrl =
    let
        url =
            baseUrl ++ "/v1/events/" ++ toString id ++ "/" ++ slug
    in
        HttpBuilder.get url
            |> withHeader "Authorization" token
            |> withExpect (Http.expectJson Data.Event.decoder)
            |> send Messages.GetEventResponse


onLocationChange : Model -> Navigation.Location -> ( Model, Cmd Msg )
onLocationChange model location =
    let
        newRoute =
            getRoute location
    in
        case ( newRoute, model.token ) of
            ( Public r, _ ) ->
                ( { model | route = newRoute }, commandForRoute newRoute model.token model.baseUrl )

            ( Private r, Just token ) ->
                ( { model | route = newRoute }, commandForRoute newRoute model.token model.baseUrl )

            ( Private r, Nothing ) ->
                ( { model | route = newRoute }, commandForAuthToken )


commandForAuthToken : Cmd Msg
commandForAuthToken =
    getLocalStorageItem "authToken"


postCreateEvent : String -> String -> Cmd Msg
postCreateEvent baseUrl encodedData =
    Http.send Messages.CreateEventResponse <|
        getCreateEventRequest (baseUrl ++ "/v1/events") (Http.stringBody "application/json" encodedData)


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
                            Decode.decodeString Data.Event.decoder r.body
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


extractHeader : String -> Http.Response a -> Maybe String
extractHeader name response =
    Dict.get name response.headers


port getLocalStorageItem : String -> Cmd msg


port getLocalStorageItemResponse : (( String, Maybe String ) -> msg) -> Sub msg


port setLocalStorageItem : LocalStorageRecord -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ getLocalStorageItemResponse Messages.LocalStorageResponse
        , Phoenix.Socket.listen model.phxSocket Messages.PhoenixMsg
        ]


main : Program Flags Model Msg
main =
    Navigation.programWithFlags Messages.UrlChange
        { init = onLocationChange << Model.initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
