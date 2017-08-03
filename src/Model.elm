module Model exposing (..)

import Keyboard
import Window exposing (Size)
import Task
import Time exposing (Time)

import ScanningSettings
import CommandPalette

type alias ScanState =
  { loops: Int
  , scanIndex: Int
  , elementsToScan: Int
  , isPaused: Bool
  , settings: ScanningSettings.Model
  }

type alias RegionData =
  { activeRegion : Geometry
  , childRegions: List Geometry
  , siblingRegions: List Geometry
  , action: String
  }

type alias Geometry =
  { x: Int
  , y: Int
  , width: Int
  , height: Int
  }

type alias Model =
  { index : Int
  , activeRegion: Geometry
  , siblingRegions: List Geometry
  , childRegions: List Geometry
  , isShiftDown : Bool
  , viewportSize : Size
  , scanningSettings: ScanningSettings.Model
  , commandPalette: CommandPalette.Model
  , scan: ScanState
  , page: Page
  }

init : (Model, Cmd Msg)
init =
  let
    (scanningSettingsModel, scanningSettingsCmd) = ScanningSettings.init
    (commandPaletteModel, commandPaletteCmd) = CommandPalette.init
  in
  (Model
    -1
    { x = 0, y = 0, width = 0, height = 0}
    []
    []
    False
    (Size 0 0)
    scanningSettingsModel
    commandPaletteModel
    (ScanState 0 0 0 False scanningSettingsModel)
    Website
  , Cmd.batch
      [ Task.perform WindowResize Window.size
      , Cmd.map ScanningSettings scanningSettingsCmd
      , Cmd.map CommandPalette commandPaletteCmd
      ]
  )

type Msg
  = NoOp
  | KeyDownMsg Keyboard.KeyCode
  | KeyUpMsg Keyboard.KeyCode
  | Regions RegionData
  | WindowResize Size
  | Scanning ScanMsg
  | External String
  | ScanningSettings ScanningSettings.Msg
  | CommandPalette CommandPalette.Msg
  | ChangePage Page

type Page
  = Website
  | ScanningSettingsPage

type ScanMsg
  = Scan Time
  | Pause String
  | Resume String

type Action
  = Select
  | Next
  | Previous
  | Up
  | Noop
