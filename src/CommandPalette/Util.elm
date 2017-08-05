module CommandPalette.Util exposing (..)

import CommandPalette.Types exposing (..)
import Ports

directionToPort: Direction -> Cmd Msg
directionToPort direction =
  case direction of
    North -> Ports.up 1
    West -> Ports.switchTree "Toggle"
    South -> Ports.select 1
    _ -> Cmd.none
