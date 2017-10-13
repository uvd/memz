module Styles.CreateEventPageCss exposing (..)

import Styles.Colors exposing (..)
import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = PageWrapper
    | Logo
    | Input
    | ProgressIndicator
    | FormWrapper
    | EventForm
    | Active
    | Question
    | Submit


css =
    (stylesheet << namespace "createEvent")
        [ class PageWrapper
            [ height (vh 100)
            , padding2 (px 40) (px 20)
            , boxSizing borderBox
            , fontWeight lighter
            ]
        , class FormWrapper
            [ padding2 zero (px 20)
            , textAlign left
            , fontSize (Css.rem 1.4)
            , lineHeight (Css.rem 2)
            ]
        , class EventForm
            [ position relative
            , borderBottom3 (px 1) solid colorPrimary
            ]
        , class ProgressIndicator
            [ margin zero
            , padding zero
            , textAlign left
            , marginBottom (px 10)
            , children
                [ li
                    [ display inlineBlock
                    , backgroundColor (hex "D7D6D7")
                    , width (px 8)
                    , height (px 8)
                    , marginRight (px 8)
                    , borderRadius (pct 50)
                    , withClass Active
                        [ backgroundColor colorPrimary
                        , transform (scale 1.1)
                        ]
                    ]
                ]
            ]
        , class Logo
            [ marginBottom (px 40)
            ]
        , class Question
            [ margin3 (px 0) (px 0) (px 20)
            , maxWidth (pct 65)
            ]
        , class Input
            [ border zero
            , width (pct 87)
            , fontSize (Css.rem 1.2)
            , padding2 (px 10) (px 2)
            , boxSizing borderBox
            , fontWeight lighter
            , pseudoClass ":placeholder"
                [ color colorLightGrey ]
            , pseudoClass "::-webkit-calendar-picker-indicator"
                [ display none
                , property "-webkit-appearance" "none"
                ]
            ]
        , class Submit
            [ position absolute
            , right (px 0)
            , bottom (px 10)
            , border zero
            , backgroundColor (rgba 255 255 255 0)
            , backgroundImage (url "../../assets/submit-arrow.svg")
            , backgroundRepeat noRepeat
            , width (px 26)
            ]
        ]
