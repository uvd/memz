module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (Error)
import Json.Encode as Encode


type alias Model =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
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



-- | CreateEvent
-- | CreateEventResponse (Result Http.Error String)


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
                Html.form [ onSubmit IncrementStep ]
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



-- CreateEvent ->
--     (model, postCreateEvent model)
-- CreateEventResponse (Ok d)
--     -> (model, Cmd.none)
-- CreateEventResponse (Err d)
--     -> (model, Cmd.none)


init : ( Model, Cmd Msg )
init =
    ( initialModel
    , Cmd.none
    )


bodyEncoder : { a | name : String, owner : String, endDateTime : String } -> String
bodyEncoder data =
    let
        encodedValue =
            Encode.object
                [ 
                    ( "name", Encode.string data.name ),
                    ( "owner", Encode.string data.owner ),
                    ( "endDateTime", Encode.string data.endDateTime )
                ]
    in
        Encode.encode 0 encodedValue



main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = (always Sub.none)
        }
