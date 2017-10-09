module Main exposing (..)

import Date exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
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
    { name = ""
    , owner = ""
    , endDateTime = ""
    , step = NameStep
    }


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
        [ case model.step of
            NameStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Your name", value model.name, onInput Name, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            OwnerStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Event name", value model.owner, onInput Owner, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            EndDateTimeStep ->
                Html.form [ onSubmit CreateEvent ]
                    [ input [ type_ "datetime-local", placeholder "Event date", value model.endDateTime, onInput EndDateTime, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]
        , p [] [ text (model.name ++ " " ++ model.owner ++ model.endDateTime) ]
        ]


view : Model -> Html Msg
view =
    newEvent


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Name n ->
            ( { model | name = n }, Cmd.none )

        Owner o ->
            ( { model | owner = o }, Cmd.none )

        EndDateTime d ->
            ( { model | endDateTime = d }, Cmd.none )

        IncrementStep ->
            let
                currentStep =
                    model.step
            in
            ( { model | step = incrementCurrentStep currentStep }, Cmd.none )

        CreateEvent ->
            ( model, postCreateEvent (bodyEncoder { name = model.name, owner = model.owner, endDateTime = model.endDateTime }) )

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
