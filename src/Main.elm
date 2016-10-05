module Main exposing (..)

import Html
    exposing
        ( Html
        , Attribute
        , audio
        , button
        , div
        , text
        )
import Html.App
import Html.Attributes
    exposing
        ( class
        , classList
        , controls
        , id
        , src
        , style
        , type'
        )
import Html.Events exposing (on, onClick)
import Json.Decode as Json exposing (Decoder)
import Ports
import String


-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , playing : Bool
    , currentTime : Float
    , duration : Float
    , playbackRate : Float
    , playbackStep : Float
    , playheadPosition : Float
    , playButton : Bool
    , pauseButton : Bool
    , slowerButton : Bool
    , fasterButton : Bool
    , resetPlaybackButton : Bool
    }



-- MSG


type Msg
    = TimeUpdate Float
    | SetDuration Float
    | Playing
    | Paused
    | Play
    | Pause
    | Slower
    | Faster
    | ResetPlayback



-- INIT


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "https://mdn.mozillademos.org/files/2587/AudioTest (1).ogg"
    , mediaType = "audio/ogg"
    , playing = False
    , currentTime = 0.0
    , duration = 0.0
    , playbackRate = 1.0
    , playbackStep = 0.1
    , playheadPosition = 0.0
    , playButton = True
    , pauseButton = False
    , slowerButton = True
    , fasterButton = True
    , resetPlaybackButton = True
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate time ->
            ( { model
                | currentTime = time
                , playheadPosition = updatePlayhead time model.duration
              }
            , Cmd.none
            )

        SetDuration duration ->
            ( { model | duration = duration }, Cmd.none )

        Playing ->
            ( { model
                | playing = True
                , playButton = False
                , pauseButton = True
              }
            , Cmd.none
            )

        Paused ->
            ( { model
                | playing = False
                , playButton = True
                , pauseButton = False
              }
            , Cmd.none
            )

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


updatePlayhead : Float -> Float -> Float
updatePlayhead currentTime duration =
    currentTime / duration * 100



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- JSON Decoders


onEnded : msg -> Attribute msg
onEnded msg =
    on "ended" (Json.succeed msg)


onLoadedMetadata : (Float -> msg) -> Attribute msg
onLoadedMetadata msg =
    on "loadedmetadata" (Json.map msg targetDuration)


onPause : msg -> Attribute msg
onPause msg =
    on "pause" (Json.succeed msg)


onPlaying : msg -> Attribute msg
onPlaying msg =
    on "play" (Json.succeed msg)


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float


targetDuration : Decoder Float
targetDuration =
    Json.at [ "target", "duration" ] Json.float



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "player" ]
        [ audio
            [ id "elm-audio-file"
            , src model.mediaUrl
            , type' model.mediaType
            , onLoadedMetadata SetDuration
            , onTimeUpdate TimeUpdate
            , onPause Paused
            , onPlaying Playing
            , onEnded Paused
            ]
            []
        , div [ class "controls" ]
            [ controlButton model.playButton Play "Play"
            , controlButton model.pauseButton Pause "Pause"
            , controlButton model.slowerButton Slower "-"
            , controlButton model.fasterButton Faster "+"
            , controlButton model.resetPlaybackButton ResetPlayback "Reset"
            , div [ class "timeline" ]
                [ div
                    [ class "playhead"
                    , style [ ( "left", toString model.playheadPosition ++ "%" ) ]
                    ]
                    []
                ]
            , div [ class "time" ]
                [ text
                    ((model.currentTime
                        |> round
                        |> formatTime
                     )
                        ++ " | "
                        ++ (model.duration
                                |> round
                                |> formatTime
                           )
                    )
                ]
            ]
        ]


formatTime : Int -> String
formatTime time =
    let
        hours =
            time // 3600 |> padTimeString

        minutes =
            time % 3600 // 60 |> padTimeString

        seconds =
            time % 3600 % 60 |> padTimeString

        timeList =
            if hours == "00" then
                [ minutes, seconds ]
            else
                [ hours, minutes, seconds ]
    in
        String.join ":" timeList


padTimeString : Int -> String
padTimeString timeUnit =
    String.padLeft 2 '0' (toString timeUnit)


controlButton : Bool -> Msg -> String -> Html Msg
controlButton display msg label =
    if display then
        button
            [ class
                (msg
                    |> toString
                    |> String.toLower
                )
            , onClick msg
            ]
            [ text label ]
    else
        text ""



-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
