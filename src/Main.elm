module Main exposing (..)

import Html
    exposing
        ( Html
        , text
        )
import Html.App


-- MODEL


type alias Model =
    { src : String
    }


init : Model
init =
    { src = "example.mp3"
    }



-- UPDATE


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html msg
view model =
    text (toString model)


main : Program Never
main =
    Html.App.program
        { init = ( init, Cmd.none )
        , update = update
        , subscriptions = (\_ -> Sub.none)
        , view = view
        }
