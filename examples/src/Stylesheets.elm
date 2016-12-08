port module Stylesheets exposing (main)

import Css.File exposing (CssFileStructure, CssCompilerProgram, compile, toFileStructure)


import TodoList.Style as TodoList


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure
        [ ( "styles.css"
          , compile
                [ TodoList.css
                ]
          )
        ]


main : CssCompilerProgram
main =
    Css.File.compiler files cssFiles
