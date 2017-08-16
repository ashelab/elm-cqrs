module TodoList.Stub exposing (main)

{-|
The TodoList example showcases some of the benefits of the CQRS approach to event management

@docs main
-}


import Html exposing (Html, div)
import Html.Attributes as Attr
import Css exposing (..)

--

import CQRS exposing (..)

--

import TodoList.Model exposing (..)
import TodoList.Update as TodoList
import TodoList.View as TodoList


--


styles : List Mixin -> Html.Attribute msg
styles =
    asPairs >> Attr.style

--

view : Model -> Html Command
view model =
    div
        [ styles
            [ backgroundColor (hex "#FFF")
            , width (px 800)
            , height (px 600)
            , overflowY scroll
            ]
        ]
        [ TodoList.view model
        ]

main : Program Context Model Command
main =
    program
        { decode = TodoList.decode
        , encode = TodoList.encode
        , init = TodoList.init
        , view = view
        , commandMap = TodoList.commandMap
        , eventMap = TodoList.eventMap
        , eventHandler = eventHandler
        , subscriptions = subscriptions
        }


eventHandler : ( Model, Effect ) -> Cmd msg
eventHandler ( model, effect ) =
    case effect of
        _ ->
            Cmd.none


subscriptions : Model -> Sub Command
subscriptions model =
    Sub.batch
        []
