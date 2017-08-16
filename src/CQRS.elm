module CQRS exposing (Definition, NavDefinition, State, eventBinder, program, programWithNav, stateMap)

{-| The CQRS library provides an alternate set of methods for union routing and model updating based upon the precepts of CQRS and EventSourcing

# Types
@docs Definition
@docs NavDefinition
@docs State


# Program Bootloaders
@docs eventBinder
@docs stateMap
@docs program
@docs programWithNav

-}

import Html exposing (Html)
import Navigation exposing (Location)


{-|
The goal of the SPADefinition (Single Page App) is to simplify bootstrapping with some assumptions about execution mode
that encourage the application code to maintain purity by accepting a fully initialized Model without worrying about
data loading or location concerns.

Additionally, Commands messages are generalized into Effects which allows the program to follow an Event Sourced model
(messages as data) and helps centralize the concern of applying side effects to the main entry point level of the app.

decode:         Provides an opportunity for components to extract data from the incoming payload
encode:         Provides an opportunity for components to encode data into a persistance bundle
init:           Merges initial state from the client with the navigator data to produce the initial app context
view:           Produces (Html, Effect) that can initiate effect requests
commandMap:     Maps Commands into Events and provides an opportunity to apply business logic and / or deny the Command
eventMap:       Responsible for updating the state and / or triggering side effects
eventHandler:   Segregated handler to translate Effects into legit Elm Cmd Msg to initiate side effects
subscriptions:  Segregated handler to receive incoming side effects from the outside world and map them to Commands
-}
type alias Definition context model command event effect =
    { decode : context -> model
    , encode : model -> context
    , init : model -> ( model, Maybe effect )
    , view : model -> Html command
    , commandMap : model -> command -> event
    , eventMap : model -> event -> ( model, Maybe effect )
    , eventHandler : ( model, effect ) -> Cmd command
    , subscriptions : model -> Sub command
    }

{-|
init:           Loads initiating data and location into the app which provides initial pathing contxt
update:         Responds to the change of location
-}
type alias NavDefinition state context command =
    { init : state -> Location -> context
    , update : Location -> command
    }

{-|
State is a conventionalized organization to simplify delegation of state and messages to child components
-}
type alias State model =
    { state : model
    }

{-|
stateMap applies a modifier function to the content of a state container
-}
stateMap :
    ( model -> model )
    -> { container | state : model }
    -> { container | state : model }
stateMap mapFunc value =
    { value | state = mapFunc value.state }

-- {-|
-- Describes a structure which composes a child property containing nested state 
-- -}
-- type alias StateContainer container model =
--     { container | state : model }

-- {-|

-- -}
-- type alias StateMap model effect container containerEffect =
--     ( model, effect ) -> ( StateContainer container model, containerEffect )


{-|
Run a client side web application with state initialization

See programWithNav for an extension that introduces the notion of navigation actions
-}
program :
    Definition context model command event effect
    -> Program context model command
program def =
    Html.programWithFlags
        { init = initFunc def.decode def.init def.eventHandler
        , view = def.view
        , update = updateFunc def.commandMap def.eventMap def.eventHandler
        , subscriptions = def.subscriptions
        }


{-|
Run a client side web application with state initialization and navigation actions
-}
programWithNav :
    NavDefinition state context command
    -> Definition context model command event effect
    -> Program state model command
programWithNav nav def =
    Navigation.programWithFlags nav.update
        { init = routerInitFunc nav.init def.decode def.init <| def.eventHandler
        , view = def.view
        , update = updateFunc def.commandMap def.eventMap def.eventHandler
        , subscriptions = def.subscriptions
        }

{-|
-}
initFunc :
    (context -> model)
    -> (model -> ( model, Maybe effect ))
    -> (( model, effect ) -> Cmd command)
    -> (context -> ( model, Cmd command ))
initFunc decode init eventHandler context =
    let
        ( model, effect ) =
            init <| decode context
    in
        case effect of
            Nothing ->
                ( model, Cmd.none )

            Just effect_ ->
                ( model, eventHandler ( model, effect_ ) )


{-|
-}
routerInitFunc :
    (state -> Location -> context)
    -> (context -> model)
    -> (model -> ( model, Maybe effect ))
    -> (( model, effect ) -> Cmd command)
    -> (state -> Location -> ( model, Cmd command ))
routerInitFunc router decode init eventHandler state location =
    let
        context =
            router state location

        ( model, effect ) =
            init <| decode context
    in
        case effect of
            Nothing ->
                ( model, Cmd.none )
            Just effect_ ->
                ( model, eventHandler ( model, effect_ ) )


{-|
-}
updateFunc :
    (model -> command -> event)
    -> (model -> event -> ( model, Maybe effect ))
    -> (( model, effect ) -> Cmd command)
    -> (command -> model -> ( model, Cmd command ))
updateFunc commandMap eventMap eventHandler command model =
    let
        event =
            commandMap model command

        ( resultModel, effect ) =
            eventMap model event
    in
        case effect of
            Nothing ->
                ( resultModel, Cmd.none )
            Just effect_ ->
                ( resultModel, eventHandler ( resultModel, effect_ ) )

{-|
Simplifies the syntax for mapping of Events from parent components to child components
-}
eventBinder :
    (model -> event -> ( model, Maybe effect ))
    -> { container | state : model }
    -> ({ container | state : model } -> parentModel)
    -> (effect -> containerEffect)
    -> event
    -> (parentModel, Maybe containerEffect)
eventBinder eventMap getter setter effectMap event =
    let
        ( model, effect ) =
            eventMap getter.state event
    in
        ( setter { getter | state = model }
        , Maybe.map effectMap effect
        )    
