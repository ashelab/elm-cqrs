module TodoList.Model
    exposing
        ( Entry
        , ContextValues
        , Context
        , Model
        , Command(..)
        , Event(..)
        , Effect(..)
        , mapContext
        , defaultModel
        , newEntry
        )

type alias Entry =
    { description : String
    , completed : Bool
    , editing : Bool
    , id : Int
    }

type alias ContextValues =
    { entries : List Entry
    , field : String
    , uid : Int
    , visibility : String
    }


type alias Context =
    Maybe ContextValues


type alias Model =
    { entries : List Entry
    , field : String
    , uid : Int
    , visibility : String
    }

{-| Users of our app can trigger Commands by clicking and typing. These
commands are fed into the eventMap function as they occur, allowing us
to evaluate 
-}
type Command
    = AddEntry
    | DeleteEntry Int
    | ChangeEntryVisibility String
    | Check Int Bool
    | CheckAll Bool
    | UpdateEntry Int String
    | UpdateField String
    

type Event
    = EntryDataChanged List Entry
    | FieldUpdated String

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
    { entries = []
    , visibility = "All"
    , field = ""
    , uid = 0
    }

newEntry : String -> Int -> Entry
newEntry desc id =
    { description = desc
    , completed = False
    , editing = False
    , id = id
    }