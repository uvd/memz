port module Main exposing (..)

import Date exposing (..)
import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit, onClick)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode
import Navigation
import Dict exposing (get)


-- ROUTING


type Route
    = HomePage
    | NewEventPage


type alias NewEvent =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
    , errors : List ServerError
    }


type alias Model =
    { newEvent : NewEvent
    , route : Route
    , token : Maybe String
    }


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    , slug : String
    }


type alias EventResponse =
    ( String, Event )


type alias ServerError =
    ( String, List String )


type alias LocalStorageRecord =
    ( String, String )


type Step
    = OwnerStep
    | NameStep
    | EndDateTimeStep


type Msg
    = Name String
    | Owner String
    | EndDateTime String
    | IncrementStep
    | CreateEvent
    | CreateEventResponse (Result Http.Error EventResponse)
    | UrlChange Navigation.Location
    | SayHello


initialNewEvent : NewEvent
initialNewEvent =
    { name = ""
    , owner = ""
    , endDateTime = "2017-10-11T13:04"
    , step = OwnerStep
    , errors = []
    }


initialModel : Model
initialModel =
    { newEvent = initialNewEvent
    , route = HomePage
    , token = Nothing
    }


homePage : a -> Html msg
homePage model =
    div []
        [ p [] [ text "Long term memories made in real time" ]
        , a [ href "#create-event" ] [ text "Create an event" ]
        ]


incrementCurrentStep : Step -> Step
incrementCurrentStep step =
    case step of
        OwnerStep ->
            NameStep

        NameStep ->
            EndDateTimeStep

        s ->
            s


newEvent : Model -> Html Msg
newEvent model =
    div []
        [ case model.newEvent.step of
            OwnerStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Your name", value model.newEvent.owner, onInput Owner, required True, minlength 4, maxlength 20 ] []
                    , input [ type_ "submit", value "Next" ] []
                    , div []
                        (model.newEvent.errors
                            |> List.concatMap (\( _, errors ) -> errors)
                            |> List.map (\err -> (span [] [ text err ]))
                        )
                    ]

            NameStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Event name", value model.newEvent.name, onInput Name, required True, minlength 2, maxlength 30 ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            EndDateTimeStep ->
                Html.form [ onSubmit CreateEvent ]
                    [ input [ type_ "datetime-local", placeholder "Event date", value model.newEvent.endDateTime, onInput EndDateTime, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]
        , p [] [ text (model.newEvent.name ++ " " ++ model.newEvent.owner ++ model.newEvent.endDateTime) ]
        ]


view : Model -> Html Msg
view model =
    case model.route of
        HomePage ->
            homePage model

        NewEventPage ->
            newEvent model


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
        Name n ->
            ( updateNewEvent (\x -> { x | name = n }) model, Cmd.none )

        Owner o ->
            ( updateNewEvent (\x -> { x | owner = o }) model, Cmd.none )

        EndDateTime d ->
            ( updateNewEvent (\x -> { x | endDateTime = d }) model, Cmd.none )

        IncrementStep ->
            ( updateNewEvent (\x -> { x | step = incrementCurrentStep x.step }) model, Cmd.none )

        CreateEvent ->
            ( model, postCreateEvent (bodyEncoder model.newEvent) )

        CreateEventResponse (Result.Ok ( header, _ )) ->
            ( { model | token = Just header }, setLocalStorageItem ( "authToken", header ) )

        CreateEventResponse (Result.Err err) ->
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
                    (Debug.log ("BAD PAYLOAD ERROR" ++ err))
                        ( model, Cmd.none )

                _ ->
                    (Debug.log "ERROR")
                        ( model, Cmd.none )

        UrlChange location ->
            ( { model | route = getRoute location }, Cmd.none )

        SayHello ->
            ( model, getLocalStorageItem "hello" )


getRoute : Navigation.Location -> Route
getRoute location =
    case location.hash of
        "#create-event" ->
            NewEventPage

        _ ->
            HomePage


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( { initialModel | route = getRoute location }
    , Cmd.none
    )


postCreateEvent : String -> Cmd Msg
postCreateEvent encodedData =
    Http.send CreateEventResponse <|
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
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
