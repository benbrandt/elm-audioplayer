port module AudioPlayer exposing (..)

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
import Html.Lazy exposing (lazy, lazy2, lazy3)
import Json.Decode as Json exposing (Decoder)
import String


-- MODEL


type alias AudioFile =
    { mediaUrl : Maybe String
    , mediaType : Maybe String
    , thumbnail : Maybe String
    , title : Maybe String
    , artist : Maybe String
    }


type alias Controls =
    { slowerButton : Bool
    , fasterButton : Bool
    , resetPlaybackButton : Bool
    }


type alias Model =
    { audioFile : AudioFile
    , currentTime : Float
    , duration : Float
    , playing : Bool
    , playbackRate : Float
    , playbackStep : Float
    , playheadPosition : Float
    , controlButtons : Controls
    }



-- MSG


type Msg
    = FileUpdate AudioFile
    | TimeUpdate Float
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
    { audioFile =
        { mediaUrl = Nothing
        , mediaType = Nothing
        , thumbnail = Nothing
        , title = Nothing
        , artist = Nothing
        }
    , currentTime = 0.0
    , duration = 0.0
    , playing = False
    , playbackRate = 1.0
    , playbackStep = 0.1
    , playheadPosition = 0.0
    , controlButtons =
        { slowerButton = True
        , fasterButton = True
        , resetPlaybackButton = True
        }
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileUpdate file ->
            ( { model | audioFile = file }, playIt )

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
            ( { model | playing = True }, Cmd.none )

        Paused ->
            ( { model | playing = False }, Cmd.none )

        Play ->
            ( model, playIt )

        Pause ->
            ( model, pauseIt )

        Slower ->
            let
                newPlaybackRate =
                    model.playbackRate - model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }
                , setPlaybackRate newPlaybackRate
                )

        Faster ->
            let
                newPlaybackRate =
                    model.playbackRate + model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }
                , setPlaybackRate newPlaybackRate
                )

        ResetPlayback ->
            ( { model | playbackRate = 1 }, setPlaybackRate 1 )


updatePlayhead : Float -> Float -> Float
updatePlayhead currentTime duration =
    currentTime / duration * 100



-- PORTS


port setCurrentTime : Float -> Cmd msg


port setPlaybackRate : Float -> Cmd msg


port play : () -> Cmd msg


port pause : () -> Cmd msg


port updateAudioFile : (AudioFile -> msg) -> Sub msg


playIt : Cmd msg
playIt =
    play ()


pauseIt : Cmd msg
pauseIt =
    pause ()



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    updateAudioFile FileUpdate



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
        [ lazy viewAudioFile model.audioFile
        , div [ class "controls" ]
            [ lazy3 controlButton (not model.playing) Play "Play"
            , lazy3 controlButton model.playing Pause "Pause"
            , div [ class "playback" ]
                [ lazy3 controlButton model.controlButtons.slowerButton Slower "-"
                , lazy3 controlButton model.controlButtons.resetPlaybackButton ResetPlayback "Reset"
                , lazy3 controlButton model.controlButtons.fasterButton Faster "+"
                ]
            , lazy viewTimeline model.playheadPosition
            , lazy2 viewClock model.currentTime model.duration
            ]
        ]


viewAudioFile : AudioFile -> Html Msg
viewAudioFile file =
    case ( file.mediaUrl, file.mediaType ) of
        ( Just url, Just mediaType ) ->
            audio
                [ id "elm-audio-file"
                , src url
                , type' mediaType
                , onLoadedMetadata SetDuration
                , onTimeUpdate TimeUpdate
                , onPause Paused
                , onPlaying Playing
                , onEnded Paused
                ]
                []

        _ ->
            audio [ id "elm-audio-file" ] []


viewTimeline : Float -> Html Msg
viewTimeline position =
    div [ class "timeline" ]
        [ div
            [ class "playhead"
            , style [ ( "left", toString position ++ "%" ) ]
            ]
            []
        ]


viewClock : Float -> Float -> Html Msg
viewClock currentTime duration =
    div [ class "time" ]
        [ text
            ((currentTime
                |> round
                |> formatTime
             )
                ++ " | "
                ++ (duration
                        |> round
                        |> formatTime
                   )
            )
        ]


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



-- UTILITY FUNCTIONS


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



-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
