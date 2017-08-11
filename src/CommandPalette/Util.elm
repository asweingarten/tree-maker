module CommandPalette.Util exposing (..)

import CommandPalette.Types exposing (..)
import Ports

directionToPort: Direction -> Cmd Msg
directionToPort direction =
  case direction of
    North -> Ports.up 1
    West -> Ports.toggleTree "x"
    South -> Ports.select 1
    East -> Ports.triggerToggleScanning 1
    _ -> Cmd.none
