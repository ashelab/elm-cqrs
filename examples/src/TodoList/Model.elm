module TodoList.Model
    exposing
        ( Command(..)
        , Event(..)
        , Effect(..)
        , Context
        , ContextValues
        , TodoItem
        , Model
        , mapContext
        , defaultModel
        )


type alias ContextValues =
    { data : List TodoItem
    }


type alias Context =
    Maybe ContextValues


type alias TodoItem =
    { title : String
    }


type alias Model =
    { data : List TodoItem
    }


type Command
    = NoCommands


type Event
    = NoEvents


type Effect
    = None


mapContext : Context -> Model
mapContext context =
    Maybe.withDefault
        { data = []
        }
        context
        |> mapValues


mapValues : ContextValues -> Model
mapValues values =
  values

defaultModel : Model
defaultModel =
    { data = []
    }
