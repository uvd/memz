module Pages.HomePage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Messages exposing (Msg)


view : Html Msg
view =
    div []
        [ p [] [ text "Long term memories made in real time" ]
        , a [ href "#/create-event" ] [ text "Create an event" ]
        ]
