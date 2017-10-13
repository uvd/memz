module Styles.HomePageCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = CreateEventBtn
    | PageWrapper


css =
    (stylesheet << namespace "homepage")
        [ class CreateEventBtn
            [ backgroundColor (hex "0BC5C4")
            , color (hex "FFFFFF")
            , display inlineBlock
            , textDecoration none
            , padding2 (px 12) (px 20)
            ]
        , class PageWrapper
            [ displayFlex
            , flexDirection column
            , height (vh 100)
            , padding2 (px 40) (px 20)
            , boxSizing borderBox
            , justifyContent spaceBetween
            ]
        ]
