module CQRS exposing (Definition, program, programWithNav, eventBinder)

{-| The CQRS library provides an alternate set of methods for union routing and model updating based upon the precepts of CQRS and EventSourcing

# Types
@docs Definition

# Program Bootloaders
@docs program
@docs programWithNav
@docs eventBinder
-}

import Html exposing (Html)
import Navigation exposing (Location)


{-|

The goal of the Definition is to simplify bootstrapping with some assumptions about execution mode
that encourage the application code to maintain purity by accepting a fully initialized Model without worrying about
data loading or location concerns.
Additionally, Command and Subscription (Cmd and Sub) messages are generalized into Effects which allows the program
to follow an Event Sourced model (messages as data) and helps centralize the concern of applying side effects to the
main entry point level of the app.

* Serialization *

decode: Provides a method for loading the state passed into the application as start
encode: Provides a serialization entry for persisting / memoizing component state

* Runtime *

init: Merges initial state from the client with the navigator data to produce the initial app context
view: Produces html that can initiate effect requests
commandMap: evaluates the validity of a request for state mutation and produces an event describing the result
eventMap: applies a declared mutation to the component's state

* Side Effects *

eventHandler: Outbound side-effects which turn Effects into actions to be handled by the Elm Runtime
subscriptions: Inbound side-effects map external events into the component with it's state for context

-}
type alias Definition context model command event effect =
    { decode : context -> model
    , encode : model -> context
    , init : model -> ( model, effect )
    , view : model -> Html command
    , commandMap : model -> command -> event
    , eventMap : model -> event -> ( model, effect )
    , eventHandler : ( model, effect ) -> Cmd event
    , subscriptions : model -> Sub command
    }


type alias NavDefinition state context event =
    { init : state -> Location -> context
    , update : Location -> event
    }


{-|

-}
program : Definition context model command event effect -> Program context model event
program def =
    Html.programWithFlags
        { init = initFunc def.decode def.init def.eventHandler
        , view = viewFunc def.view def.commandMap
        , update = updateFunc def.eventMap def.eventHandler
        , subscriptions = subscribeFunc def.subscriptions def.commandMap
        }


{-|
-}
programWithNav : NavDefinition state context event -> Definition context model command event effect -> Program state model event
programWithNav nav def =
    Navigation.programWithFlags nav.update
        { init = routerInitFunc nav.init def.decode def.init <| def.eventHandler
        , view = viewFunc def.view def.commandMap
        , update = updateFunc def.eventMap def.eventHandler
        , subscriptions = subscribeFunc def.subscriptions def.commandMap
        }


initFunc : (context -> model) -> (model -> ( model, effect )) -> (( model, effect ) -> Cmd msg) -> (context -> ( model, Cmd msg ))
initFunc decode init eventHandler context =
    let
        ( model, effect ) =
            init <| decode context

        effect_ =
            eventHandler ( model, effect )
    in
        ( model, effect_ )


routerInitFunc : (state -> Location -> context) -> (context -> model) -> (model -> ( model, effect )) -> (( model, effect ) -> Cmd msg) -> (state -> Location -> ( model, Cmd msg ))
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


viewFunc : (model -> Html command) -> (model -> command -> event) -> (model -> Html event)
viewFunc view commandHandler model =
    Html.map (commandHandler model) (view model)


updateFunc : (model -> event -> ( model, effect )) -> (( model, effect ) -> Cmd msg) -> (event -> model -> ( model, Cmd msg ))
updateFunc eventMap eventHandler event model =
    let
        ( resultModel, effect ) =
            eventMap model event

        effect_ =
            eventHandler ( resultModel, effect )
    in
        ( resultModel, effect_ )

subscribeFunc : (model -> Sub command) -> (model -> command -> event) -> (model -> Sub event)
subscribeFunc sub commandHandler model =
    Sub.map (commandHandler model) (sub model)


{-|
EventBinder provides a simplified mapping interface for translating events across component hierarchies
-}
eventBinder : (parentModel -> childModel) -> (( parentModel, childModel ) -> parentModel) -> (childModel -> childEvent -> ( childModel, childEffect )) -> (parentModel -> childEffect -> parentEffect) -> parentModel -> childEvent -> ( parentModel, parentEffect )
eventBinder childGet childSet childEventMap effectMap parentModel childEvent =
    let
        ( childModel_, childEffect ) =
            childEventMap (childGet parentModel) childEvent

        effect =
            effectMap parentModel childEffect

        model =
            childSet ( parentModel, childModel_ )
    in
        ( model, effect )