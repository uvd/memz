module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Date exposing (..)
import Maybe exposing (..)


type alias Model =
    { newEvent :
        { name : Maybe String
        , owner : Maybe String
        , endDateTime : Maybe Date
        }
    }


type Msg =
    Name String


initialModel : Model
initialModel =
    { newEvent =
        { name = Nothing
        , owner = Nothing
        , endDateTime = Nothing
        }
    }


homePage model =
    p [] [ text "Long term memories made in real time" ]


newEvent: Model -> Html Msg
newEvent model =
    div [] [
        input [type_ "text", placeholder "Your name", value (Maybe.withDefault "" model.newEvent.name)]
        []
    ]
    -- (case model.newEvent.name of
    --   Nothing -> []
    --   Just name -> [text name])]


view : Model -> Html Msg
view =
    newEvent


update : Msg -> Model -> Model
update msg model =
    model


main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
