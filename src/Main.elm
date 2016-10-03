module Main exposing (..)

import Debug
import Html
    exposing
        ( Html
        , audio
        , div
        , text
        )
import Html.App
import Html.Attributes
    exposing
        ( class
        , controls
        , id
        , src
        , type'
        )


-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    }



-- MSG


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "https://mdn.mozillademos.org/files/2587/AudioTest (1).ogg"
    , mediaType = "audio/ogg"
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            Debug.log "Unkown message" ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html msg
view model =
    div [ class "elm-audioplayer" ]
        [ audio
            [ id "audio-player"
            , src model.mediaUrl
            , type' model.mediaType
            , controls True
            ]
            []
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = (\_ -> Sub.none)
        , view = view
        }
