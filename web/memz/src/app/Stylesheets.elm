port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import MyCss
import Styles.HomePageCss as HomePageCss
import Styles.CreateEventPageCss as CreateEventPageCss
import Styles.EventPageCss as EventPageCss


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "main.css", Css.File.compile [ MyCss.css, HomePageCss.css, CreateEventPageCss.css, EventPageCss.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
