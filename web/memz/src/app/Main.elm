module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)


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


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name n ->
            { model | name = n }

        Owner o ->
            { model | owner = o }

        EndDateTime d ->
            { model | endDateTime = d }

        IncrementStep ->
            let
                currentStep =
                    model.step
            in
                { model | step = incrementCurrentStep currentStep }


main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
