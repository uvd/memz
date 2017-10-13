port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import MyCss
import Styles.HomePageCss as HomePageCss


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css", Css.File.compile [ MyCss.css, HomePageCss.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
