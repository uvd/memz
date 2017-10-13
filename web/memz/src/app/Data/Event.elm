module Data.Event exposing (..)

import Json.Decode as Decode


type alias Photo =
    { path : String
    , owner : String
    , date : String
    }


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    , slug : String
    }


type Status
    = Idle
    | Uploading


type alias CurrentEvent =
    { event : Maybe Event
    , photos : List Photo
    , status : Status
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


photoDecoder : Decode.Decoder Photo
photoDecoder =
    Decode.map3
        Photo
        (Decode.at [ "path" ] Decode.string)
        (Decode.at [ "owner" ] Decode.string)
        (Decode.at [ "date" ] Decode.string)
