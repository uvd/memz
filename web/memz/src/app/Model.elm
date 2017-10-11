module Model exposing (..)

import Messages exposing (Event)


type PublicRoute
    = HomePageRoute


type PrivateRoute
    = CreateEventRoute
    | EventRoute Int String


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
    , event : Maybe Messages.Event
    }


toRoute : Route -> Route
toRoute r =
    r


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
    , route = Public HomePageRoute
    , token = Nothing
    , event = Nothing
    }
