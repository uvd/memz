module Pages.HomePage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Messages exposing (Msg)
import Styles.HomePageCss exposing (..)
import Html.CssHelpers exposing (withNamespace)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "homepage"


view : Html Msg
view =
    div [ class [ PageWrapper ] ]
        [ div []
            [ img [ Html.Attributes.src "assets/logo.svg" ] []
            ]
        , div []
            [ p [] [ Html.text "Long term memories made in real time" ]
            ]
        , div []
            [ a [ href "#/create-event", class [ CreateEventBtn ] ] [ Html.text "Create an event" ]
            ]
        ]
