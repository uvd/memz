module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Date exposing (..)
import Maybe exposing (..)


type alias Model =
    { name : String
    , owner : String
    , endDateTime : String
    }
    
    
type Msg =
    Name String | Owner String | EndDateTime String

        
initialModel : Model
initialModel =
    { name = ""
    , owner = ""
    , endDateTime = ""
    }
    

homePage model =
    p [] [ text "Long term memories made in real time" ]


newEvent: Model -> Html Msg
newEvent model =
    div [] [
        input [type_ "text", placeholder "Your name", value model.name, onInput Name] [],
        input [type_ "text", placeholder "Event name", value model.owner, onInput Owner] [],
        input [type_ "datetime-local", placeholder "Event date", value model.endDateTime] [],
        p [] [text (model.name ++ " " ++ model.owner ++ model.endDateTime)]
    ]
    -- (case model.newEvent.name of
    --   Nothing -> []
    --   Just name -> [text name])]


view : Model -> Html Msg
view =
    newEvent


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name n -> {model | name = n}
        Owner o -> {model | owner = o}
        EndDateTime d -> {model | endDateTime = d}


main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }
