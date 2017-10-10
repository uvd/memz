module Model exposing (..)


type Route
    = HomePageRoute
    | CreateEventRoute
      
type Step
    = OwnerStep
    | NameStep
    | EndDateTimeStep
      
type alias ServerError =
    ( String, List String )

type alias NewEvent =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
    , errors : List ServerError
    }


type alias Model =
    { newEvent : NewEvent
    , route : Route
    , token : Maybe String
    }


initialNewEvent : NewEvent
initialNewEvent =
    { name = ""
    , owner = ""
    , endDateTime = "2017-10-11T13:04"
    , step = OwnerStep
    , errors = []
    }

initialModel : Model
initialModel =
    { newEvent = initialNewEvent
    , route = HomePageRoute
    , token = Nothing
    }
