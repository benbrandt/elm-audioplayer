module Main exposing (..)

import AudioPlayer
import Controls
import Html exposing (Html, div, text)
import Html.App
import Html.Attributes exposing (class)


-- MODEL


type alias Model =
    { audioPlayer : AudioPlayer.Model
    , controls : Controls.Model
    }



-- MSG


type Msg
    = MsgAudioPlayer AudioPlayer.Msg
    | MsgControls Controls.Msg



-- INIT


init : ( Model, Cmd Msg )
init =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            AudioPlayer.init

        ( controlsInit, controlsCmds ) =
            Controls.init
    in
        { audioPlayer = audioPlayerInit
        , controls = controlsInit
        }
            ! [ Cmd.batch
                    [ Cmd.map MsgAudioPlayer audioPlayerCmds
                    , Cmd.map MsgControls controlsCmds
                    ]
              ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgAudioPlayer msg' ->
            let
                ( audioPlayerModel, audioPlayerCmds ) =
                    AudioPlayer.update msg' model.audioPlayer
            in
                ( { model | audioPlayer = audioPlayerModel }
                , Cmd.map MsgAudioPlayer audioPlayerCmds
                )

        MsgControls msg' ->
            let
                ( controlsModel, controlsCmds ) =
                    Controls.update msg' model.controls
            in
                ( { model | controls = controlsModel }
                , Cmd.map MsgControls controlsCmds
                )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "player-wrapper" ]
        [ Html.App.map MsgAudioPlayer (AudioPlayer.view model.audioPlayer)
        , Html.App.map MsgControls (Controls.view model.controls)
        , text (toString model)
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
