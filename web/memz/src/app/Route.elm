module Route exposing (..)

import UrlParser exposing ((</>), Parser, int, map, oneOf, parseHash, s, string)
import Navigation


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
    case parseHash route location of
        Just route ->
            route

        _ ->
            Public HomePageRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ UrlParser.map (\id slug -> Private (EventRoute id slug)) (UrlParser.s "event" </> int </> string)
        , UrlParser.map (Public CreateEventRoute) (UrlParser.s "create-event")
        ]
