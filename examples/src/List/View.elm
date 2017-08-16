module List.View exposing (..)

import Html exposing (..)
-- import Html.Attributes as Attr
-- import Html.Events exposing (onClick)

--

import List.Model exposing (..)
import List.Style exposing (..)



--


{ id, class, classList } =
    cssNamespace



--



-- VIEW ALL ENTRIES


viewEntries : String -> List Entry -> Html Msg
viewEntries visibility entries =
    let
        isVisible todo =
            case visibility of
                "Completed" ->
                    todo.completed

                "Active" ->
                    not todo.completed

                _ ->
                    True

        allCompleted =
            List.all .completed entries

        cssVisibility =
            if List.isEmpty entries then
                "hidden"
            else
                "visible"
    in
        section
            [ class "main"
            , style [ ( "visibility", cssVisibility ) ]
            ]
            [ input
                [ class "toggle-all"
                , type_ "checkbox"
                , name "toggle"
                , checked allCompleted
                , onClick (CheckAll (not allCompleted))
                ]
                []
            , label
                [ for "toggle-all" ]
                [ text "Mark all as complete" ]
            , Keyed.ul [ class "todo-list" ] <|
                List.map viewKeyedEntry (List.filter isVisible entries)
            ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedEntry : Entry -> ( String, Html Msg )
viewKeyedEntry todo =
    ( toString todo.id, lazy viewEntry todo )


viewEntry : Entry -> Html Msg
viewEntry todo =
    li
        [ classList [ ( "completed", todo.completed ), ( "editing", todo.editing ) ] ]
        [ div
            [ class "view" ]
            [ input
                [ class "toggle"
                , type_ "checkbox"
                , checked todo.completed
                , onClick (Check todo.id (not todo.completed))
                ]
                []
            , label
                [ onDoubleClick (EditingEntry todo.id True) ]
                [ text todo.description ]
            , button
                [ class "destroy"
                , onClick (Delete todo.id)
                ]
                []
            ]
        , input
            [ class "edit"
            , value todo.description
            , name "title"
            , id ("todo-" ++ toString todo.id)
            , onInput (UpdateEntry todo.id)
            , onBlur (EditingEntry todo.id False)
            , onEnter (EditingEntry todo.id False)
            ]
            []
        ]
