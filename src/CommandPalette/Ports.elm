port module CommandPalette.Ports exposing (..)

import Window exposing (Size)

import Mouse exposing (Position)

port clicks : (Position -> msg) -> Sub msg
port moves : (Position -> msg) -> Sub msg

port screenSize : (Size -> msg) -> Sub msg
