module App.Stub exposing (main)

{-|
The TodoList App example showcases some of the benefits of the CQRS approach to event management

@docs main
-}


import Html exposing (Html, div)
import Html.Attributes as Attr
import Css exposing (..)

--

import CQRS exposing (..)

--

import App.Model exposing (..)
import App.Update as App
import App.View as App


--


styles : List Mixin -> Html.Attribute msg
styles =
    asPairs >> Attr.style

--

view : Model -> Html Command
view model =
    div
        [ styles
            [ backgroundColor (hex "#DDD")
            , width (vw 100)
            , height (vh 100)
            , overflowY scroll
            ]
        ]
        [ App.view model
        ]

main : Program Context Model Command
main =
    program
        { decode = App.decode
        , encode = App.encode
        , init = App.init
        , view = view
        , commandMap = App.commandMap
        , eventMap = App.eventMap
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
