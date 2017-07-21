module KeyDown exposing (update)

import Keyboard exposing (KeyCode)
import Debug exposing (log)

import Model exposing (..)
import Ports

update : Model -> KeyCode -> (Model, Cmd Msg)
update model keycode =
  let _ = log "keycode" keycode
  in
  case (keycode, model.isShiftDown) of
    -- Enter
    (13, _) -> (model, Ports.select 1)
    -- If shift is down, then make sure you do the right thing
    (9, False) -> (model, Ports.next 1)
    (9, True) -> (model, Ports.up 1)
    (192, _) -> (model, Ports.up 1) -- ` for ps4 support
    (16, _) -> ({ model | isShiftDown = True }, Cmd.none)
    -- Backspace
    (8, _) -> (model, Ports.previous 1)
    _ -> (model, Cmd.none)
