module Tests exposing (..)

import Test exposing (..)
import Expect
import AudioPlayer


all : Test
all =
    describe "A Test Suite"
        [ test "updatePlayhead" <|
            \() ->
                AudioPlayer.updatePlayhead 7.308 9.135
                    |> Expect.equal 80
        , test "Time Formatting" <|
            \() ->
                AudioPlayer.formatTime 3601
                    |> Expect.equal "01:00:01"
        , test "Time Formatting 2" <|
            \() ->
                AudioPlayer.formatTime 3599
                    |> Expect.equal "59:59"
        , test "Time Formatting 3" <|
            \() ->
                AudioPlayer.formatTime 360001
                    |> Expect.equal "100:00:01"
        ]
