module Model exposing (..)

import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Messages exposing (..)
import Data.Event exposing (..)


type PublicRoute
    = HomePageRoute
    | CreateEventRoute


type PrivateRoute
    = EventRoute Int String


type Route
    = Public PublicRoute
    | Private PrivateRoute


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
    , event : Maybe Event
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initialNewEvent : NewEvent
initialNewEvent =
    { name = ""
    , owner = ""
    , endDateTime = "2017-11-11T13:04"
    , step = OwnerStep
    , errors = []
    }


initialModel : Model
initialModel =
    { newEvent = initialNewEvent
    , route = Public HomePageRoute
    , token = Nothing
    , event = Nothing
    , phxSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
    }
