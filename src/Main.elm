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
        , controls
        , id
        , src
        , type'
        )
import Html.Events exposing (on, onClick)
import Json.Decode


-- MODEL


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , currentTime : Float
    }



-- MSG


type Msg
    = TimeUpdate Float
    | SetPlayerTime Float


init : ( Model, Cmd Msg )
init =
    { mediaUrl = "https://mdn.mozillademos.org/files/2587/AudioTest (1).ogg"
    , mediaType = "audio/ogg"
    , currentTime = 0.0
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate time ->
            ( { model | currentTime = time }, Cmd.none )

        SetPlayerTime newTime ->
            ( model, setCurrentTime newTime )



-- Custom event handler


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.Decode.map msg targetCurrentTime)



-- Json.Decoder to grab `event.target.currentTime`


targetCurrentTime : Json.Decode.Decoder Float
targetCurrentTime =
    Json.Decode.at [ "target", "currentTime" ] Json.Decode.float



-- PORTS


port setCurrentTime : Float -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "elm-audioplayer" ]
        [ audio
            [ id "audio-player"
            , src model.mediaUrl
            , type' model.mediaType
            , controls True
            , onTimeUpdate TimeUpdate
            ]
            []
        , div [] [ text (toString model.currentTime) ]
        , button [ onClick (SetPlayerTime 2.0) ] [ text "Set current time to 2s" ]
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , subscriptions = (\_ -> Sub.none)
        , view = view
        }
