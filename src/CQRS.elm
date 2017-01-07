module CQRS exposing (Definition, NavDefinition, State, program, programWithNav, eventBinder)

{-| The CQRS library provides an alternate set of methods for union routing and model updating based upon the precepts of CQRS and EventSourcing

# Types
@docs Definition
@docs NavDefinition
@docs State


# Program Bootloaders
@docs program
@docs programWithNav
@docs eventBinder
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
    , init : model -> ( model, effect )
    , view : model -> Html command
    , commandMap : model -> command -> event
    , eventMap : model -> event -> ( model, effect )
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

-- {-|
-- -}
-- type alias EventMap model event effect =
--     model -> event -> ( model, effect )

{-|
Describes a structure which composes a child property containing nested state 
-}
type alias StateContainer container model =
    { container | state : model }

{-|

-}
type alias StateMap model effect container containerEffect =
    ( model, effect ) -> ( StateContainer container model, containerEffect )


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
    -> (model -> ( model, effect ))
    -> (( model, effect ) -> Cmd command)
    -> (context -> ( model, Cmd command ))
initFunc decode init eventHandler context =
    let
        ( model, effect ) =
            init <| decode context

        effect_ =
            eventHandler ( model, effect )
    in
        ( model, effect_ )

{-|
-}
routerInitFunc :
    (state -> Location -> context)
    -> (context -> model)
    -> (model -> ( model, effect ))
    -> (( model, effect ) -> Cmd command)
    -> (state -> Location -> ( model, Cmd command ))
routerInitFunc router decode init eventHandler state location =
    let
        context =
            router state location

        ( model, effect ) =
            init <| decode context

        effect_ =
            eventHandler ( model, effect )
    in
        ( model, effect_ )

{-|
-}
updateFunc :
    (model -> command -> event)
    -> (model -> event -> ( model, effect ))
    -> (( model, effect ) -> Cmd command)
    -> (command -> model -> ( model, Cmd command ))
updateFunc commandMap eventMap eventHandler command model =
    let
        event =
            commandMap model command

        ( resultModel, effect ) =
            eventMap model event

        effect_ =
            eventHandler ( resultModel, effect )
    in
        ( resultModel, effect_ )

{-|
Simplifies the syntax for mapping of Events from parent components to child components
-}
eventBinder :
    (model -> event -> ( model, effect ))
    -> { container | state : model }
    -> (( { container | state : model }, effect ) -> containerEffect)
    -> event
    -> containerEffect
eventBinder eventMap container containerMap event =
    let
        ( model, effect ) =
            eventMap container.state event
    in
        containerMap ( { container | state = model }, effect )
