module CommandPalette.Dwell exposing (update)

import Time exposing (Time)
import Debug exposing (log)

import CommandPalette.Types exposing (..)
import CommandPalette.Util exposing (directionToPort)
import Ports

update : Model -> DwellCommand -> Direction -> Time -> (Model, Cmd Msg)
update model command direction time =
  let
    updatedCommand = { command | progress = command.progress + 1 }
    thresholdReached = updatedCommand.progress == updatedCommand.threshold
  in
    case (model.activeCommand, model.candidateCommand, thresholdReached) of
      (Just activeCommand, Nothing, True) ->
        let
          _ = log "command about to be fired" activeCommand
        in
        ({ model | activeCommand = Nothing, isActive = False, direction = Nothing }
        , directionToPort activeCommand.direction)
      (Just activeCommand, Nothing, False) ->
        ({ model | activeCommand = Just updatedCommand }, Cmd.none)
      (Just activeCommand, Just candidateCommand, True) ->
        let
          didUpdateActiveCommand = activeCommand.direction == updatedCommand.direction
          _ = log "active, cand, and thresholdReached" activeCommand.progress
        in
        case didUpdateActiveCommand of
          True ->
            -- Active Command is fired
            ({ model | activeCommand = Nothing, isActive = False, candidateCommand = Nothing }
            , directionToPort activeCommand.direction)
          False ->
            -- Candidate Command takes over
            let
              newActiveCmd = Just { candidateCommand | threshold = 10 }
            in
            ({ model | activeCommand = newActiveCmd, candidateCommand = Nothing }
            , Cmd.none)
      (Just activeCommand, Just candidateCommand, False) ->
        let updatedActiveCommand = activeCommand.direction == updatedCommand.direction
        in
        case updatedActiveCommand of
          True ->
            -- update the active command
            ({ model | activeCommand = Just updatedCommand }
            , Cmd.none)
          False ->
            -- update the candidate command
            ({ model | candidateCommand = Just updatedCommand }
            , Cmd.none)
      (_,_,_) -> (model, Cmd.none)
