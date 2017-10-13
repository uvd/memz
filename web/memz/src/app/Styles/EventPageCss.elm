module Styles.EventPageCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = PageWrapper
    | Header
    | Footer
    | Content
    | Stream


css =
    (stylesheet << namespace "event")
        [ class PageWrapper
            [ height (vh 100)
            , displayFlex
            , flexDirection column
            , boxSizing borderBox
            ]
        , class Header
            [ property "flex" "0 0 auto"
            , padding (px 5)
            ]
        , class Content
            [ property "flex" "1 1 auto"
            , position relative
            , overflowY auto
            ]
        , class Footer
            [ property "flex" "0 0 auto"
            , padding (px 5)
            ]
        ]
