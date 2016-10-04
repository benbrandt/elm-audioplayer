port module Ports exposing (..)

-- PORTS


port setCurrentTime : Float -> Cmd msg


port setPlaybackRate : Float -> Cmd msg


port play : () -> Cmd msg


port pause : () -> Cmd msg


playIt : Cmd msg
playIt =
    play ()


pauseIt : Cmd msg
pauseIt =
    pause ()
