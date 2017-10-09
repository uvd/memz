module Main exposing (..)

import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode


type alias NewEvent =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
    }


type alias Model =
    { newEvent : NewEvent
    }


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    }


type Step
    = NameStep
    | OwnerStep
    | EndDateTimeStep


type Msg
    = Name String
    | Owner String
    | EndDateTime String
    | IncrementStep
    | CreateEvent
    | CreateEventResponse (Result Http.Error Event)


initialModel : Model
initialModel =
    { newEvent =
        { name = ""
        , owner = ""
        , endDateTime = ""
        , step = NameStep
        }
    }


homePage : a -> Html msg
homePage model =
    p [] [ text "Long term memories made in real time" ]


incrementCurrentStep : Step -> Step
incrementCurrentStep step =
    case step of
        NameStep ->
            OwnerStep

        OwnerStep ->
            EndDateTimeStep

        s ->
            s


newEvent : Model -> Html Msg
newEvent model =
    div []
        [ case model.newEvent.step of
            NameStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Your name", value model.newEvent.name, onInput Name, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            OwnerStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Event name", value model.newEvent.owner, onInput Owner, required True ] []
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
view =
    newEvent


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

        CreateEventResponse (Result.Ok d) ->
            ( model, Cmd.none )

        CreateEventResponse (Result.Err d) ->
            ( model, Cmd.none )


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )


postCreateEvent : String -> Cmd Msg
postCreateEvent encodedData =
    Http.send CreateEventResponse <|
        Http.post "/v1/events" (Http.stringBody "application/json" encodedData) responseDecoder


bodyEncoder : { a | name : String, owner : String, endDateTime : String } -> String
bodyEncoder data =
    let
        encodedValue =
            Encode.object
                [ ( "event"
                  , Encode.object
                        [ ( "name", Encode.string data.name )
                        , ( "owner", Encode.string data.owner )
                        , ( "endDateTime", Encode.string data.endDateTime )
                        ]
                  )
                ]
    in
    Encode.encode 0 encodedValue


responseDecoder : Decode.Decoder Event
responseDecoder =
    Decode.map4
        Event
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "owner" ] Decode.string)
        (Decode.at [ "endDateTime" ] Decode.string)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
