module Styles.EventPageCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = PageWrapper


css =
    (stylesheet << namespace "event")
        [ class PageWrapper
            [ displayFlex
            , flexDirection column
            , height (vh 100)
            , padding2 (px 40) (px 20)
            , boxSizing borderBox
            , justifyContent spaceBetween
            ]
        ]
