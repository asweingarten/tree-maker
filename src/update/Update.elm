module Update exposing (update)

import Debug exposing (log)

import Model exposing (..)
import KeyDown
import Regions
import Ports
import ScanState
import ScanningSettings

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
    KeyDownMsg code ->
      KeyDown.update model code
    KeyUpMsg code ->
      case code of
        16 -> ({ model | isShiftDown = False }, Cmd.none)
        _ -> (model, Cmd.none)
    Regions regionData ->
      Regions.update model regionData
    WindowResize size ->
      ({ model | viewportSize = size }, Cmd.none)
    Scanning msg ->
      let scan = model.scan
      in
      case msg of
        Scan time ->
          -- update scan state
          (model, Ports.next 1)
        Pause _ ->
          ({model | scan = {scan | isPaused = True}}
          , Cmd.none)
        Resume _ ->
          ({model | scan = {scan | isPaused = False}}
          , Cmd.none)
    ScanningSettings msg ->
      let (scanningSettings, cmd) = ScanningSettings.update model.scanningSettings msg
      in
      ({ model | scanningSettings = scanningSettings }
      , Cmd.map ScanningSettings cmd)
    ChangePage page ->
      ({ model | page = page }, Ports.switchTree <| toString page)
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
