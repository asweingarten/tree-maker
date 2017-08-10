module Update exposing (update)

import Debug exposing (log)

import Model exposing (..)
import KeyDown
import Regions
import Ports
import ScanState
import ScanningSettings
import CommandPalette
import CommandPalette.Types exposing (Msg(ActivateActiveCommand))

update : Model.Msg -> Model -> (Model, Cmd Model.Msg)
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
          ({model | scan = {scan | isPaused = False } }
          , Cmd.none)
    ScanningSettings msg ->
      let (scanningSettings, cmd) = ScanningSettings.update model.scanningSettings msg
      in
      ({ model | scanningSettings = scanningSettings }
      , Cmd.map ScanningSettings cmd)
    CommandPalette msg ->
      -- what do when sub-modules should impact the global state?
      let (commandPalette, cmd) = CommandPalette.update msg model.commandPalette
      in
      ({ model | commandPalette = commandPalette }
      , Cmd.map CommandPalette cmd)
    ChangePage page ->
      ({ model | page = page, showCommandPalette = False }
      , Ports.switchTree <| toString page)
    ToggleCommandPalette ->
      let
        cp = model.commandPalette
        newCp = {cp | isOpen = not cp.isOpen }
      in
      ({ model | showCommandPalette = not model.showCommandPalette, commandPalette = newCp }, Cmd.none)
    HideCommandPalette foo ->
      ({ model | showCommandPalette = False }, Cmd.none)
    Myo foo ->
      let
        activeCommand = model.commandPalette.commandPalette.activeCommand
      in
      case activeCommand of
        Just command ->
          let
            (newModel, cmd) = update (CommandPalette ActivateActiveCommand) model
            page =
              case (command.direction, model.page) of
                (CommandPalette.Types.West, Website) -> ScanningSettingsPage
                (CommandPalette.Types.West, ScanningSettingsPage) -> Website
                (_, _) -> model.page
          in
          ({ newModel | page = page }, Cmd.batch [cmd])
        Nothing ->
          (model, Ports.select 1)
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
