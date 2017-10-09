import Html exposing (..)
import Date exposing (..)
import Maybe exposing (..)

type alias Model =
    {
        newEvent :
            {
                name: Maybe String,
                owner: Maybe String,
                endDateTime: Maybe Date
            }
    }

type alias Msg = ()

initialModel =
    {
        newEvent =
            {
                name = Nothing,
                owner = Nothing,
                endDateTime = Nothing
            }
    }

homePage model =
    p [] [text "Long term memories made in real time"]

newEvent model =
    div [] []

view : Model -> Html Msg
view =
    newEvent

update : Msg -> Model -> Model
update msg model = model


main = Html.beginnerProgram
    {
        model = initialModel,
        view = view,
        update = update
    }