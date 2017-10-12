module Messages exposing (..)

import Navigation
import Http
import Data.Event exposing (..)
import Phoenix.Socket
import Json.Encode
import FileReader exposing (NativeFile)


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
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | EventChannelJoined Json.Encode.Value
    | PhotoSelected (List NativeFile)
    | UploadPhoto (Result FileReader.Error (List Json.Encode.Value))
