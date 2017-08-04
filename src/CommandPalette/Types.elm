module CommandPalette.Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)
import Window exposing(Size)

type alias CommandPalette =
  { dimensions: Square
  , isActive: Bool
  , activeCommand: Maybe DwellCommand
  , candidateCommand: Maybe DwellCommand
  , activationTimeInMillis: Float
  }

type alias Model =
  { mousePosition: Position
  , commandPalette: CommandPalette
  , gazePosition: Position
  , windowSize : Size
  , screenSize : Size
  , direction : Maybe Direction
  , showConfiguration : Bool
  }

type Direction
  = West
  | East
  | North
  | South
  | Northwest
  | Northeast
  | Southwest
  | Southeast

type alias DwellCommand =
  { direction : Direction
  , progress  : Int
  , threshold : Int
  }

type Msg
  = CursorMoved Position
  | Dwell DwellCommand Direction Time
  | ChangeDirection Direction
  | WindowResize Size
  | ScreenSize Size
  | SetActivationTime String
  | PauseScanning

type alias Square =
  { x: Int
  , y: Int
  , sideLength: Int
  }
