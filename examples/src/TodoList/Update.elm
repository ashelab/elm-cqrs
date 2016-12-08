module TodoList.Update exposing (..)

import TodoList.Model exposing (..)


--


decode : Context -> Model
decode =
    mapContext


encode : Model -> Context
encode _ =
    Nothing


init : Model -> ( Model, Effect )
init model =
    ( model, None )


commandMap : Model -> Command -> Event
commandMap model command =
    let
        t1 =
            Debug.log "TodoList CommandMap Command" command
    in
        case command of
           NoCommands -> NoEvents


eventMap : Model -> Event -> ( Model, Effect )
eventMap model event =
    let
        t1 =
            Debug.log "TodoList EventMap Event" event
    in
          ( model, None)
