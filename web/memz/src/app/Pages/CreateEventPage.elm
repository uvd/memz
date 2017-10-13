module Pages.CreateEventPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages exposing (Msg)
import Model exposing (Model, Step)
import Styles.CreateEventPageCss exposing (..)
import Html.CssHelpers exposing (withNamespace)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "createEvent"


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
    div [ class [ PageWrapper ] ]
        [ div [ class [ Logo ] ]
            [ img [ Html.Attributes.src "assets/logo.svg" ] []
            ]
        , div [ class [ FormWrapper ] ]
            [ div []
                [ ul [ class [ ProgressIndicator ] ]
                    [ li [ classList [ ( Active, model.newEvent.step == Model.OwnerStep ) ] ] []
                    , li [ classList [ ( Active, model.newEvent.step == Model.NameStep ) ] ] []
                    , li [ classList [ ( Active, model.newEvent.step == Model.EndDateTimeStep ) ] ] []
                    ]
                ]
            , div [ class [ EventForm ] ]
                [ case model.newEvent.step of
                    Model.OwnerStep ->
                        div []
                            [ p [ class [ Question ] ] [ text "Whats your name?" ]
                            , Html.form [ onSubmit Messages.IncrementStep ]
                                [ input [ type_ "text", class [ Input ], placeholder "Your name", value model.newEvent.owner, onInput Messages.Owner, required True, minlength 4, maxlength 20 ] []
                                , input [ type_ "submit", class [ Submit ], value " " ] []
                                , div []
                                    (model.newEvent.errors
                                        |> List.concatMap (\( _, errors ) -> errors)
                                        |> List.map (\err -> span [] [ text err ])
                                    )
                                ]
                            ]

                    Model.NameStep ->
                        div []
                            [ p [ class [ Question ] ] [ text ("Hi " ++ model.newEvent.owner ++ ", What's the occasion?") ]
                            , Html.form [ onSubmit Messages.IncrementStep ]
                                [ input [ type_ "text", class [ Input ], placeholder "Event name", value model.newEvent.name, onInput Messages.Name, required True, minlength 2, maxlength 30 ] []
                                , input [ type_ "submit", class [ Submit ], value " " ] []
                                ]
                            ]

                    Model.EndDateTimeStep ->
                        div []
                            [ p [ class [ Question ] ] [ text ("When will " ++ model.newEvent.name ++ " end?") ]
                            , Html.form [ onSubmit Messages.CreateEvent ]
                                [ input [ type_ "datetime-local", class [ Input ], placeholder "Event date", value model.newEvent.endDateTime, onInput Messages.EndDateTime, required True ] []
                                , input [ type_ "submit", class [ Submit ], value " " ] []
                                ]
                            ]
                ]
            ]
        ]
