module Controls exposing (Model, Msg(..), init, view, update)

import Html
    exposing
        ( Html
        , button
        , div
        , text
        )
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Ports


-- MODEL


type alias Model =
    { play : Bool
    , pause : Bool
    , slower : Bool
    , faster : Bool
    , resetPlayback : Bool
    , playbackRate : Float
    , playbackStep : Float
    }



-- MSG


type Msg
    = Play
    | Pause
    | Slower
    | Faster
    | ResetPlayback



-- INIT


init : ( Model, Cmd Msg )
init =
    { play = True
    , pause = False
    , slower = True
    , faster = True
    , resetPlayback = True
    , playbackRate = 1.0
    , playbackStep = 0.1
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Play ->
            ( model, Ports.playIt )

        Pause ->
            ( model, Ports.pauseIt )

        Slower ->
            let
                newPlaybackRate =
                    model.playbackRate - model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }
                , Ports.setPlaybackRate
                    newPlaybackRate
                )

        Faster ->
            let
                newPlaybackRate =
                    model.playbackRate + model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }
                , Ports.setPlaybackRate
                    newPlaybackRate
                )

        ResetPlayback ->
            ( { model | playbackRate = 1 }, Ports.setPlaybackRate 1 )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "controls" ]
        [ controlButton model.play Play "Play"
        , controlButton model.pause Pause "Pause"
        , controlButton model.slower Slower "Slower"
        , controlButton model.faster Faster "Faster"
        , controlButton model.resetPlayback ResetPlayback "Reset playback"
        ]


controlButton : Bool -> Msg -> String -> Html Msg
controlButton display msg label =
    if display then
        button [ onClick msg ] [ text label ]
    else
        text ""
