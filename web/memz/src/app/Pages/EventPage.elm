module Pages.EventPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Messages exposing (Msg)
import Model exposing (..)


view : Model -> Html Msg
view model =
    case model.event of
        Nothing ->
            div [] [ text "Page loading" ]

        Just event ->
            div []
                [ h1 [] [ text event.name ]
                , p [] [ text ("Created by " ++ event.owner) ]
                ]
