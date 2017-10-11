module Pages.CreateEventPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg)
import Model exposing (Model, Step)


incrementCurrentStep : Step -> Step
incrementCurrentStep step =
    case step of
        Model.OwnerStep ->
            Model.NameStep

        Model.NameStep ->
            Model.EndDateTimeStep

        s ->
            s



-- VIEW --


view : Model -> Html Msg
view model =
    div []
        [ case model.newEvent.step of
            Model.OwnerStep ->
                Html.form [ onSubmit Messages.IncrementStep ]
                    [ input [ type_ "text", placeholder "Your name", value model.newEvent.owner, onInput Messages.Owner, required True, minlength 4, maxlength 20 ] []
                    , input [ type_ "submit", value "Next" ] []
                    , div []
                        (model.newEvent.errors
                            |> List.concatMap (\( _, errors ) -> errors)
                            |> List.map (\err -> span [] [ text err ])
                        )
                    ]

            Model.NameStep ->
                Html.form [ onSubmit Messages.IncrementStep ]
                    [ input [ type_ "text", placeholder "Event name", value model.newEvent.name, onInput Messages.Name, required True, minlength 2, maxlength 30 ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]

            Model.EndDateTimeStep ->
                Html.form [ onSubmit Messages.CreateEvent ]
                    [ input [ type_ "datetime-local", placeholder "Event date", value model.newEvent.endDateTime, onInput Messages.EndDateTime, required True ] []
                    , input [ type_ "submit", value "Next" ] []
                    ]
        , p [] [ text (model.newEvent.name ++ " " ++ model.newEvent.owner ++ model.newEvent.endDateTime) ]
        ]
