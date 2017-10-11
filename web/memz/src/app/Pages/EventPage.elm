module Pages.EventPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Messages exposing (Msg)


view : Html Msg
view = 
    p [] [text "This is an event"]