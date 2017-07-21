module Update exposing (update)

import Debug exposing (log)

import Model exposing (..)
import KeyDown
import Highlight
import Ports

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyDownMsg code ->
      KeyDown.update model code
    KeyUpMsg code ->
      case code of
        16 -> ({ model | isShiftDown = False }, Cmd.none)
        _ -> (model, Cmd.none)
    Highlight geometry ->
      Highlight.update model geometry
    WindowResize size ->
      ({ model | viewportSize = size }, Cmd.none)
    External cmdString ->
      let
        cmd =
          case cmdString of
            "Up" -> Ports.up 1
            "Select" -> Ports.select 1
            "Next" -> Ports.next 1
            "Previous" -> Ports.previous 1
            _ -> Cmd.none
      in
      (model, cmd)
