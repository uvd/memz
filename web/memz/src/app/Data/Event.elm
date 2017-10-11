module Data.Event exposing (..)

import Json.Decode as Decode


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    , slug : String
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
