module Messages exposing (..)

import Navigation
import Http
import Model exposing (..)


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
    | GetEventResponse (Result Http.Error Event)
    | LocalStorageResponse ( String, Maybe String )
