module CommandPalette.Dwell exposing (update)

import Time exposing (Time)
import Debug exposing (log)

import CommandPalette.Types exposing (..)
-- import CommandPalette.Ports as Ports
import Ports

update : Model -> DwellCommand -> Direction -> Time -> (Model, Cmd Msg)
update model command direction time =
  let
    c = model.commandPalette
    updatedCommand = { command | progress = command.progress + 1 }
    thresholdReached = updatedCommand.progress == updatedCommand.threshold
  in
    case (c.activeCommand, c.candidateCommand, thresholdReached) of
      (Just activeCommand, Nothing, True) ->
        let
          cmdP = { c | activeCommand = Nothing, isActive = False }
          _ = log "command about to be fired" activeCommand
        in
        ({ model | commandPalette = cmdP, direction = Nothing }
        , directionToPort activeCommand.direction)
      (Just activeCommand, Nothing, False) ->
        let
          cmdP = { c | activeCommand = Just updatedCommand }
        in
        ({ model | commandPalette = cmdP }, Cmd.none)
      (Just activeCommand, Just candidateCommand, True) ->
        let
          updatedActiveCommand = activeCommand.direction == updatedCommand.direction
          _ = log "active, cand, and thresholdReached" activeCommand.progress
        in
        case updatedActiveCommand of
          True ->
            -- Active Command is fired
            let
              cmdP = { c | activeCommand = Nothing, isActive = False, candidateCommand = Nothing }
            in
            ({ model | commandPalette = cmdP }
            , directionToPort activeCommand.direction)
          False ->
            -- Candidate Command takes over
            let newActiveCmd = Just { candidateCommand | threshold = 10 }
                cmdP = { c | activeCommand = newActiveCmd, candidateCommand = Nothing }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)

      (Just activeCommand, Just candidateCommand, False) ->
        let updatedActiveCommand = activeCommand.direction == updatedCommand.direction
        in
        case updatedActiveCommand of
          True ->
            -- update the active command
            let cmdP = { c | activeCommand = Just updatedCommand }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)
          False ->
            -- update the candidate command
            let cmdP = { c | candidateCommand = Just updatedCommand }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)
      (_,_,_) -> (model, Cmd.none)

directionToPort: Direction -> Cmd Msg
directionToPort direction =
  case direction of
    North -> Ports.up 1
    West -> Ports.previous 1
    South -> Ports.select 1
    _ -> Cmd.none
