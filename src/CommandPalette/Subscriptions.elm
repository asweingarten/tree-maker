module CommandPalette.Subscriptions exposing (subscriptions)

import Time exposing (every, millisecond)
import Window

import CommandPalette.Types exposing (..)
import CommandPalette.Ports as Ports

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Ports.moves CursorMoved
    , Window.resizes WindowResize
    , dwellCommandSubscription model
    ]

dwellCommandSubscription : Model -> Sub Msg
dwellCommandSubscription commandPalette =
  let
    activeCommand = commandPalette.activeCommand
    candidateCommand = commandPalette.candidateCommand
    activationTimeInMillis = commandPalette.activationTimeInMillis / 10
  in
  case (activeCommand, candidateCommand) of
    (Just activeCmd, Just candidateCmd) ->
      every (activationTimeInMillis * millisecond) (Dwell candidateCmd candidateCmd.direction)
    (Just activeCmd, Nothing) ->
      every (activationTimeInMillis * millisecond) (Dwell activeCmd activeCmd.direction)
    (Nothing, _) ->
      Sub.none
