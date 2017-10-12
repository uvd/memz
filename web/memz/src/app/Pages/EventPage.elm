module Pages.EventPage exposing (..)

import Data.Event exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Messages exposing (Msg)
import Model exposing (..)
import FileReader


view : Model -> Html Msg
view model =
    case model.event of
        Nothing ->
            div [] [ text "Page loading" ]

        Just event ->
            div []
                [ header []
                    [ h1 [] [ text event.name ]
                    , p [] [ text ("Created by " ++ event.owner) ]
                    ]
                , ul
                    []
                    (List.map renderPhoto event.photos)
                , input
                    [ type_ "file"
                    , accept "image/*"
                    , FileReader.onFileChange Messages.PhotoSelected
                    ]
                    []
                ]


renderPhoto : Photo -> Html Msg
renderPhoto photo =
    li []
        [ img [ src photo.path ] []
        , div []
            [ span []
                [ text photo.name ]
            , span []
                [ text photo.date ]
            ]
        ]
