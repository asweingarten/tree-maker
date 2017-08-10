module CommandPalette.Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)
import Window exposing(Size)

type alias Model =
  { direction : Maybe Direction
  , isOpen: Bool
  , dimensions: Square
  , isActive: Bool
  , activeCommand: Maybe DwellCommand
  , candidateCommand: Maybe DwellCommand
  , activationTimeInMillis: Float
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
  | SetActivationTime String
  | PauseScanning
  | ActivateActiveCommand

type alias Square =
  { x: Int
  , y: Int
  , sideLength: Int
  }
