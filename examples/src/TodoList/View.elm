module TodoList.View exposing (..)

import Html exposing (..)
-- import Html.Attributes as Attr
-- import Html.Events exposing (onClick)

--

import TodoList.Model exposing (..)
import TodoList.Style exposing (..)



--


{ id, class, classList } =
    cssNamespace



--



view : Model -> Html Command
view model =
    div
        [ class [ Component ]
        ]
        [ text "TodoList"
        ]
