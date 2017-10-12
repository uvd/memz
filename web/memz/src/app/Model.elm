module Model exposing (..)

import Phoenix.Socket
import Messages exposing (..)
import Data.Event exposing (..)
import Route exposing (..)


type Step
    = OwnerStep
    | NameStep
    | EndDateTimeStep


type alias ServerError =
    ( String, List String )


type alias Flags =
    { baseUrl : String }


type alias NewEvent =
    { name : String
    , owner : String
    , endDateTime : String
    , step : Step
    , errors : List ServerError
    }


type alias Model =
    { newEvent : NewEvent
    , currentEvent : CurrentEvent
    , route : Route
    , token : Maybe String
    , phxSocket : Phoenix.Socket.Socket Msg
    , baseUrl : String
    }


initialNewEvent : NewEvent
initialNewEvent =
    { name = ""
    , owner = ""
    , endDateTime = "2017-11-11T13:04"
    , step = OwnerStep
    , errors = []
    }


initialCurrentEvent : CurrentEvent
initialCurrentEvent =
    { event = Nothing
    , photos = []
    , status = Idle
    }


initialModel : Flags -> Model
initialModel flags =
    { newEvent = initialNewEvent
    , currentEvent = initialCurrentEvent
    , route = Public HomePageRoute
    , token = Nothing
    , phxSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
    , baseUrl = flags.baseUrl
    }
