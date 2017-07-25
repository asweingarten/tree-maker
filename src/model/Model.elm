module Model exposing (..)

import Keyboard
import Window exposing (Size)
import Task

type alias HighlightData =
  { activeRegion : Geometry
  , childRegions: List Geometry
  , siblingRegions: List Geometry
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
  , Task.perform WindowResize Window.size)

type Msg
  = KeyDownMsg Keyboard.KeyCode
  | KeyUpMsg Keyboard.KeyCode
  | Highlight HighlightData
  | WindowResize Size
  | External String
