module CommandPalette.ChangeDirection exposing (update)

import CommandPalette.Types exposing (..)

update : Model -> Direction -> (Model, Cmd Msg)
update model newDirection =
  let
    activeCommand =
      case model.activeCommand of
        Nothing -> { direction = newDirection, progress = 0, threshold = 10 }
        Just command ->
          case (command.direction |> isEquivalentTo newDirection, command.progress > 0) of
            (_, True) -> command
            (True, False) -> command
            (False, False) -> DwellCommand newDirection 0 10
    candidateCmd = candidateCommand activeCommand model.candidateCommand newDirection
  in
    ({model | direction = Just newDirection, activeCommand = Just activeCommand, candidateCommand = candidateCmd}, Cmd.none)

candidateCommand : DwellCommand -> Maybe DwellCommand -> Direction -> Maybe DwellCommand
candidateCommand activeCommand previousCandidate currentDirection =
  case (activeCommand.progress, activeCommand.direction |> isEquivalentTo currentDirection) of
    (0, _) -> Nothing
    (_, True) -> Nothing
    (_, False) ->
      case previousCandidate of
        Just previousCand ->
          case (previousCand.direction |> isEquivalentTo currentDirection) of
            True -> Just previousCand
            False -> Just (DwellCommand currentDirection 0 activeCommand.progress)
        Nothing -> Just (DwellCommand currentDirection 0 activeCommand.progress)

isEquivalentTo : Direction -> Direction -> Bool
isEquivalentTo curDir newDir =
  case curDir of
    North -> newDir == curDir || newDir == Northeast || newDir == Northwest
    South -> newDir == curDir || newDir == Southeast || newDir == Southwest
    East  -> newDir == curDir || newDir == Northeast || newDir == Southeast
    West  -> newDir == curDir || newDir == Northwest || newDir == Southwest
    _     -> False
