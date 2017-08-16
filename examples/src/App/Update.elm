module App.Update exposing (..)

import App.Model exposing (..)


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
    case Debug.log "App CommandMap Command" command of
        UpdateField newValue ->
        


eventMap : Model -> Event -> ( Model, Effect )
eventMap model event =
    case Debug.log "App EventMap Event" event of
        DeleteComplete ->
            ( model, None )
        
        EditingEntry index editing ->
            ( model, None )

        FieldUpdated newValue ->
            ( { model | field = newValue }, None )
