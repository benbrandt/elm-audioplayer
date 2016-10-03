port module Main exposing (..)

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
        , id
        , src
        , style
        , type'
        )
import Html.Events exposing (on, onClick)
import Json.Decode


-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , currentTime : Float
    , playheadPosition : Float
    , duration : Float
    , playing : Bool
    }



-- MSG


type Msg
    = TimeUpdate Float
    | ToggleAudio
    | SetPlayerTime Float
    | SetDuration Float


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "https://mdn.mozillademos.org/files/2587/AudioTest (1).ogg"
    , mediaType = "audio/ogg"
    , currentTime = 0.0
    , playheadPosition = 0.0
    , duration = 0.0
    , playing = False
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

        ToggleAudio ->
            ( { model | playing = not model.playing }, toggleAudioState (not model.playing) )

        SetPlayerTime newTime ->
            ( model, setCurrentTime newTime )

        SetDuration duration ->
            ( { model | duration = duration }, Cmd.none )


updatePlayhead : Float -> Float -> Float
updatePlayhead currentTime duration =
    currentTime / duration * 100



-- Once Metadata loaded, grab duration


onLoadedMetadata : (Float -> msg) -> Attribute msg
onLoadedMetadata msg =
    on "loadedmetadata" (Json.Decode.map msg targetDuration)


targetDuration : Json.Decode.Decoder Float
targetDuration =
    Json.Decode.at [ "target", "duration" ] Json.Decode.float



-- On timeUpdate grab currentTime


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.Decode.map msg targetCurrentTime)


targetCurrentTime : Json.Decode.Decoder Float
targetCurrentTime =
    Json.Decode.at [ "target", "currentTime" ] Json.Decode.float



-- PORTS


port setCurrentTime : Float -> Cmd msg


port toggleAudioState : Bool -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "elm-audioplayer" ]
        [ audio
            [ id "elm-audio-file"
            , src model.mediaUrl
            , type' model.mediaType
            , onLoadedMetadata SetDuration
            , onTimeUpdate TimeUpdate
            ]
            []
        , div [ class "audioplayer" ]
            [ button
                [ classList
                    [ ( "play", True )
                    , ( "pause"
                      , (model.playing
                            && model.playheadPosition
                            < 100.0
                        )
                      )
                    ]
                , onClick ToggleAudio
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
        , text (toString model)
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = (\_ -> Sub.none)
        , view = view
        }
