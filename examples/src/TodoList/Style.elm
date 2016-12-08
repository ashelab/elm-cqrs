module TodoList.Style
    exposing
        ( CssClasses(..)
        , CssIds(..)
        , cssNamespace
        , css
        )

import Css exposing (..)
import Html.CssHelpers exposing (Namespace, withNamespace)
import Css.Namespace exposing (namespace)


type CssClasses
    = Component


type CssIds
    = None


cssNamespace : Namespace String a b c
cssNamespace =
    withNamespace "TodoList_"

css : Stylesheet
css =
    (stylesheet << namespace cssNamespace.name)
        [ (.) Component
            [
            ]
        ]
