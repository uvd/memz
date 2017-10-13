module Route exposing (..)

import UrlParser exposing ((</>), Parser, int, map, oneOf, parseHash, s, string)
import Navigation
import Utilities exposing (..)


type PublicRoute
    = HomePageRoute
    | CreateEventRoute


type PrivateRoute
    = EventRoute Int String


type Route
    = Public PublicRoute
    | Private PrivateRoute


getRoute : Navigation.Location -> Route
getRoute location =
    parseHash route location
        |> Maybe.withDefault (Public HomePageRoute)


route : Parser (Route -> a) a
route =
    oneOf
        [ UrlParser.map (Private <<< EventRoute) (UrlParser.s "event" </> int </> string)
        , UrlParser.map (Public CreateEventRoute) (UrlParser.s "create-event")
        ]
