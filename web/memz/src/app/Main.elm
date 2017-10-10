module Main exposing (..)

import Date exposing (..)
import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode
import Navigation


-- ROUTING


type Route
    = HomePage
    | NewEventPage


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
    }


type alias Event =
    { id : Int
    , name : String
    , owner : String
    , endDateTime : String
    }


type alias ServerError =
    ( String, List String )


type Step
    = NameStep
    | OwnerStep
    | EndDateTimeStep


type Msg
    = Name String
    | Owner String
    | EndDateTime String
    | IncrementStep
    | CreateEvent
    | CreateEventResponse (Result Http.Error Event)
    | UrlChange Navigation.Location


initialNewEvent : NewEvent
initialNewEvent =
    { name = ""
    , owner = ""
    , endDateTime = ""
    , step = NameStep
    , errors = []
    }
      
initialModel : Model
initialModel =
    { newEvent = initialNewEvent
    , route = HomePage
    }


homePage : a -> Html msg
homePage model =
    div []
        [ p [] [ text "Long term memories made in real time" ]
        , a [ href "#create-event" ] [ text "Create an event" ]
        ]


incrementCurrentStep : Step -> Step
incrementCurrentStep step =
    case step of
        NameStep ->
            OwnerStep

        OwnerStep ->
            EndDateTimeStep

        s ->
            s


newEvent : Model -> Html Msg
newEvent model =
    div []
        [ case model.newEvent.step of
            NameStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Your name", value model.newEvent.name, onInput Name, required True, minlength 4, maxlength 20 ] []
                    , input [ type_ "submit", value "Next" ] []
                    , div [] (model.newEvent.errors
                                  |> List.concatMap (\(_, errors) -> errors)
                                  |> List.map (\err -> (span [] [text err])))
                    ]

            OwnerStep ->
                Html.form [ onSubmit IncrementStep ]
                    [ input [ type_ "text", placeholder "Event name", value model.newEvent.owner, onInput Owner, required True, minlength 2, maxlength 30 ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            EndDateTimeStep ->
                Html.form [ onSubmit CreateEvent ]
                    [ input [ type_ "datetime-local", placeholder "Event date", value model.newEvent.endDateTime, onInput EndDateTime, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]
        , a [ href "#create-event" ] [ text "click me!" ]
        , a [ href "#banter" ] [ text "go home!" ]
        , p [] [ text (model.newEvent.name ++ " " ++ model.newEvent.owner ++ model.newEvent.endDateTime) ]
        ]


view : Model -> Html Msg
view model =
    case model.route of
        HomePage ->
            homePage model

        NewEventPage ->
            newEvent model


updateNewEvent : (NewEvent -> NewEvent) -> Model -> Model
updateNewEvent update m =
    let
        updatedNewEvent =
            update m.newEvent
    in
    { m | newEvent = updatedNewEvent }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Name n ->
            ( updateNewEvent (\x -> { x | name = n }) model, Cmd.none )

        Owner o ->
            ( updateNewEvent (\x -> { x | owner = o }) model, Cmd.none )

        EndDateTime d ->
            ( updateNewEvent (\x -> { x | endDateTime = d }) model, Cmd.none )

        IncrementStep ->
            ( updateNewEvent (\x -> { x | step = incrementCurrentStep x.step }) model, Cmd.none )

        CreateEvent ->
            ( model, postCreateEvent (bodyEncoder model.newEvent) )

        CreateEventResponse (Result.Ok d) ->
            ( model, Cmd.none )

        CreateEventResponse (Result.Err err) ->
            case err of
                Http.BadStatus badResponse ->
                    let
                        decodedResponse =
                            Decode.decodeString errorResponseDecoder badResponse.body
                        updatedModel = {model | newEvent = initialNewEvent}
                    in
                    case decodedResponse of
                        Ok serverErrors ->
                            ( updateNewEvent (\x -> { x | errors = serverErrors }) updatedModel, Cmd.none )

                        Err _ ->
                            ( updatedModel, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UrlChange location ->
            ({ model | route = getRoute location}, Cmd.none)


getRoute: Navigation.Location -> Route
getRoute location =
    case location.hash of
        "#create-event" -> NewEventPage
        _ -> HomePage                       

                        
init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( {initialModel | route = getRoute location}
    , Cmd.none
    )


postCreateEvent : String -> Cmd Msg
postCreateEvent encodedData =
    Http.send CreateEventResponse <|
        Http.post "http://localhost:3000/v1/events" (Http.stringBody "application/json" encodedData) responseDecoder


bodyEncoder : { a | name : String, owner : String, endDateTime : String } -> String
bodyEncoder data =
    let
        encodedValue =
            Encode.object
                [ ( "event"
                  , Encode.object
                        [ ( "name", Encode.string data.name )
                        , ( "owner", Encode.string data.owner )
                        , ( "endDateTime", Encode.string data.endDateTime )
                        ]
                  )
                ]
    in
    Encode.encode 0 encodedValue


errorResponseDecoder : Decode.Decoder (List ServerError)
errorResponseDecoder =
    Decode.at [ "errors" ] (Decode.keyValuePairs (Decode.list Decode.string))


responseDecoder : Decode.Decoder Event
responseDecoder =
    Decode.map4
        Event
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "owner" ] Decode.string)
        (Decode.at [ "endDateTime" ] Decode.string)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
