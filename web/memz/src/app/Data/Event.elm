module Data.Event exposing (..)

import Json.Decode as Decode


type alias Photo =
    { path : String
    , name : String
    , date : String
    }


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    , slug : String
    , photos : List Photo
    }



-- SERIALISATION --


decoder : Decode.Decoder Event
decoder =
    Decode.at [ "data" ]
        (Decode.map5
            Event
            (Decode.at [ "id" ] Decode.int)
            (Decode.at [ "name" ] Decode.string)
            (Decode.at [ "owner" ] Decode.string)
            (Decode.at [ "end_date" ] Decode.string)
            (Decode.at [ "slug" ] Decode.string)
        )
        |> Decode.map (\x -> x [ { path = "http://placekitten.com/200/300", name = "James", date = "Today, 12:30pm" } ])


photoDecoder : Decode.Decoder Photo
photoDecoder =
    Decode.map3
        Photo
        (Decode.at [ "path" ] Decode.string)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "date" ] Decode.string)
