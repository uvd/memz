module Messages exposing (..)
import Navigation
import Http

type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    , slug : String
    }


type alias EventResponse =
    ( String, Event )

type Msg
    = Name String
    | Owner String
    | EndDateTime String
    | IncrementStep
    | CreateEvent
    | CreateEventResponse (Result Http.Error EventResponse)
    | UrlChange Navigation.Location
