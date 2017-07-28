module Model exposing (..)

import Keyboard
import Window exposing (Size)
import Task
import Time exposing (Time)

type alias ScanningSettings =
  { isOn: Bool
  , interval: Float -- in milliseconds
  , loops: Int
  }

type alias ScanState =
  { loops: Int
  , scanIndex: Int
  , elementsToScan: Int
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
  , scanningSettings: ScanningSettings
  , scanState: ScanState
  }

init : (Model, Cmd Msg)
init =
  (Model
    -1
    { x = 0, y = 0, width = 0, height = 0}
    []
    []
    False
    (Size 0 0)
    (ScanningSettings False 2000 2)
    (ScanState 0 0 0)
  , Task.perform WindowResize Window.size)

type Msg
  = KeyDownMsg Keyboard.KeyCode
  | KeyUpMsg Keyboard.KeyCode
  | Regions RegionData
  | WindowResize Size
  | Scanning ScanMsg
  | External String

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
