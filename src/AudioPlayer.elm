port module AudioPlayer exposing (..)

import Html exposing (Html, Attribute)
import Html.App
import Html.Attributes
import Html.Events
import Html.Lazy
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


type alias Model =
    { audioFile : AudioFile
    , currentTime : Float
    , duration : Float
    , playing : Bool
    , playbackRate : Float
    , playbackStep : Float
    , speedControl : Bool
    , volumeControl : Bool
    , logo : Maybe String
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
    | SetTime Float
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
    , playbackStep = 0.25
    , speedControl = True
    , volumeControl = True
    , logo = Just "https://unsplash.it/60"
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileUpdate file ->
            ( { model
                | audioFile = file
                , playing = True
              }
            , playIt
            )

        TimeUpdate time ->
            ( { model | currentTime = time }, Cmd.none )

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

        SetTime time ->
            ( model, setCurrentTime time )

        Slower ->
            let
                newPlaybackRate =
                    model.playbackRate - model.playbackStep

                validatedRate =
                    validatePlaybackRate model.playbackRate
                        newPlaybackRate
            in
                ( { model | playbackRate = validatedRate }
                , setPlaybackRate validatedRate
                )

        Faster ->
            let
                newPlaybackRate =
                    model.playbackRate + model.playbackStep

                validatedRate =
                    validatePlaybackRate model.playbackRate
                        newPlaybackRate
            in
                ( { model | playbackRate = validatedRate }
                , setPlaybackRate validatedRate
                )

        ResetPlayback ->
            ( { model | playbackRate = 1 }, setPlaybackRate 1 )


validatePlaybackRate : Float -> Float -> Float
validatePlaybackRate currentRate newRate =
    if (newRate > 0.0 && newRate < 3.0) then
        newRate
    else
        currentRate



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
    Html.Events.on "ended" (Json.succeed msg)


onInputRange : (Float -> msg) -> Attribute msg
onInputRange msg =
    Html.Events.on "input" (Json.map msg targetRangeValue)


onLoadedMetadata : (Float -> msg) -> Attribute msg
onLoadedMetadata msg =
    Html.Events.on "loadedmetadata" (Json.map msg targetDuration)


onPause : msg -> Attribute msg
onPause msg =
    Html.Events.on "pause" (Json.succeed msg)


onPlaying : msg -> Attribute msg
onPlaying msg =
    Html.Events.on "play" (Json.succeed msg)


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    Html.Events.on "timeupdate" (Json.map msg targetCurrentTime)


targetCurrentTime : Decoder Float
targetCurrentTime =
    Json.at [ "target", "currentTime" ] Json.float


targetDuration : Decoder Float
targetDuration =
    Json.at [ "target", "duration" ] Json.float


targetRangeValue : Decoder Float
targetRangeValue =
    Json.at [ "target", "valueAsNumber" ] Json.float



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.Lazy.lazy viewAudioFile model.audioFile
        , Html.div [ Html.Attributes.class "player" ]
            [ Html.Lazy.lazy2 viewImg model.audioFile.thumbnail "thumbnail"
            , Html.Lazy.lazy3 controlButton (not model.playing) Play "Play"
            , Html.Lazy.lazy3 controlButton model.playing Pause "Pause"
            , Html.Lazy.lazy2 viewSpeedControls
                model.speedControl
                model.playbackRate
            , Html.Lazy.lazy2 viewTimeline model.currentTime model.duration
            , Html.Lazy.lazy2 viewClock model.currentTime model.duration
            , Html.Lazy.lazy2 viewImg model.logo "logo"
            ]
        ]


viewAudioFile : AudioFile -> Html Msg
viewAudioFile file =
    case ( file.mediaUrl, file.mediaType ) of
        ( Just url, Just mediaType ) ->
            Html.audio
                [ Html.Attributes.id "elm-audio-file"
                , Html.Attributes.src url
                , Html.Attributes.type' mediaType
                , onLoadedMetadata SetDuration
                , onTimeUpdate TimeUpdate
                , onPause Paused
                , onPlaying Playing
                , onEnded Paused
                ]
                []

        _ ->
            Html.audio [ Html.Attributes.id "elm-audio-file" ] []


viewImg : Maybe String -> String -> Html Msg
viewImg src class =
    case src of
        Just src ->
            Html.img [ Html.Attributes.src src, Html.Attributes.class class ] []

        Nothing ->
            Html.text ""


viewTimeline : Float -> Float -> Html Msg
viewTimeline position duration =
    Html.input
        [ Html.Attributes.class "timeline"
        , Html.Attributes.type' "range"
        , Html.Attributes.max (toString duration)
        , Html.Attributes.step "0.01"
        , Html.Attributes.value (toString position)
        , onInputRange SetTime
        ]
        []


viewClock : Float -> Float -> Html Msg
viewClock currentTime duration =
    Html.div [ Html.Attributes.class "time" ]
        [ Html.text
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


viewSpeedControls : Bool -> Float -> Html Msg
viewSpeedControls display playbackRate =
    if display then
        Html.div [ Html.Attributes.class "playback" ]
            [ controlButton display Slower "-"
            , controlButton display
                ResetPlayback
                (toString playbackRate ++ "x")
            , controlButton display Faster "+"
            ]
    else
        Html.text ""


controlButton : Bool -> Msg -> String -> Html Msg
controlButton display msg label =
    if display then
        Html.button
            [ Html.Attributes.class
                (msg
                    |> toString
                    |> String.toLower
                )
            , Html.Events.onClick msg
            ]
            [ Html.text label ]
    else
        Html.text ""



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
