module AudioPlayer
    exposing
        ( Model
        , Msg(..)
        , init
        , update
        , view
        , subscriptions
        )

import Html
    exposing
        ( Html
        , Attribute
        , audio
        , button
        , div
        , text
        )
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


-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , playing : Bool
    , currentTime : Float
    , controls : Bool
    , duration : Float
    , playheadPosition : Float
    }


type Msg
    = TimeUpdate Float
    | SetDuration Float
    | Playing
    | Paused



-- INIT


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "https://mdn.mozillademos.org/files/2587/AudioTest (1).ogg"
    , mediaType = "audio/ogg"
    , playing = False
    , currentTime = 0.0
    , controls = False
    , duration = 0.0
    , playheadPosition = 0.0
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
            ( { model | playing = True }, Cmd.none )

        Paused ->
            ( { model | playing = False }, Cmd.none )


updatePlayhead : Float -> Float -> Float
updatePlayhead currentTime duration =
    currentTime / duration * 100



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- JSON Decoders


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
    div []
        [ audio
            [ id "elm-audio-file"
            , src model.mediaUrl
            , type' model.mediaType
            , controls model.controls
            , onLoadedMetadata SetDuration
            , onTimeUpdate TimeUpdate
            , onPause Paused
            , onPlaying Playing
            ]
            []
        , div [ class "timeline" ]
            [ div
                [ class "playhead"
                , style [ ( "left", toString model.playheadPosition ++ "%" ) ]
                ]
                []
            ]
        ]
