module App.Model
  exposing
    ( ContextValues
    , Context
    , Model
    , Command(..)
    , Event(..)
    , Effect(..)
    , mapContext
    , defaultModel
    )

type alias ContextValues =
  {}

type alias Context =
  Maybe ContextValues

type alias Model =
  {}

type Command
  = NoCommands

type Event
  = NoEvents

type Effect
  = None

mapContext : Context -> Model
mapContext context =
    Maybe.withDefault
        defaultModel
        context
        |> mapValues


mapValues : ContextValues -> Model
mapValues values =
  values

defaultModel : Model
defaultModel =
    {}