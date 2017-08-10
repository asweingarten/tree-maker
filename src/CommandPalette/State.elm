module CommandPalette.State exposing (init, update)

import Mouse exposing (Position)
import Task
import Window exposing (Size)
import Debug

import CommandPalette.Types exposing (Model, Msg(..), Direction(..), Square)
import CommandPalette.ChangeDirection as ChangeDirection
import CommandPalette.Dwell as Dwell
import CommandPalette.Ports as Ports
import CommandPalette.Util exposing (directionToPort)

init : (Model, Cmd Msg)
init =
  (Model
    Nothing
    False
    { x = 920, y = 500, sideLength = 115 }
    False
    Nothing
    Nothing
    3000
  , Task.perform WindowResize Window.size)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PauseScanning -> (model, Cmd.none)
    CursorMoved newPosition ->
      case model.isOpen of
        True -> onCursorMoved newPosition model
        False -> (model, Cmd.none)
    Dwell command direction time ->
      let (updatedModel, cmd) = Dwell.update model command direction time
      in
      (updatedModel, cmd)
    ChangeDirection direction ->
      ChangeDirection.update model direction
    WindowResize wSize ->
      -- update command palette size and position
      let
        cmdPX = (wSize.width |> toFloat) / 2 |> round
        cmdPY = (wSize.height |> toFloat) / 2 |> round
        cmdPSideLength = (wSize.height |> toFloat) / 5 |> round
        newDimensions = (Square cmdPX cmdPY cmdPSideLength)
      in
      (
        { model
        | dimensions = newDimensions
        }
      , Cmd.none
      )
    SetActivationTime newTime ->
      let
        newTimeFloat = case String.toFloat newTime of
          Ok time -> time
          Err _ -> model.activationTimeInMillis
      in
      ({ model | activationTimeInMillis = newTimeFloat }
      , Cmd.none)
    ActivateActiveCommand ->
      let
        activeCommand = model.activeCommand
      in
      case activeCommand of
        Just command ->
          let
            cmd = directionToPort command.direction
          in
          ({ model | activeCommand = Nothing, candidateCommand = Nothing, isActive = False }, cmd)
        Nothing ->
          (model, Cmd.none)

onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    threshold = model.dimensions.sideLength
    deltaX = newPosition.x - model.dimensions.x
    deltaY = newPosition.y - model.dimensions.y
    (isActive, left, right, up, down) =
      -- calculated incorrectly. dominant direction should take precendence
      ( model.isActive
      , deltaX <= -threshold
      , deltaX >= threshold
      , deltaY <= -threshold
      , deltaY >= threshold
      )
    (isNewlyActive, currentDirection) =
      case (isActive, left, right, up, down) of
        (True, True, False, False, False) -> (False, Just West)
        (True, True, False, True, False) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Northwest direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just West)
                False -> (False, Just North)
        (True, True, False, False, True) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Southwest direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just West)
                False -> (False, Just South)
        (True, False, True, False, False) -> (False, Just East)
        (True, False, True, True, False) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Northeast direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just East)
                False -> (False, Just North)
        (True, False, True, False, True) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Southeast direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just East)
                False -> (False, Just South)
        (True, False, False, True, False) -> (False, Just North)
        (True, False, False, False, True) -> (False, Just South)
        (False, False, False, False, False) -> (True, Nothing)
        (_, _, _, _, _) -> (False, Nothing)
  in
  case (isNewlyActive, model.direction, currentDirection) of
    (True, _, _) ->
      ({model | isActive = True }, Ports.activated "foo")
    (False, Nothing, Just curDir) -> update (ChangeDirection curDir) model
    (False, _, Nothing) -> (model, Cmd.none)
    (False, Just prevDir, Just curDir) ->
      case prevDir |> isEquivalentTo curDir of
        True -> (model, Cmd.none)
        False -> update (ChangeDirection curDir) model


isEquivalentTo : Direction -> Direction -> Bool
isEquivalentTo curDir newDir =
  case curDir of
    North -> newDir == curDir || newDir == Northeast || newDir == Northwest
    South -> newDir == curDir || newDir == Southeast || newDir == Southwest
    East  -> newDir == curDir || newDir == Northeast || newDir == Southeast
    West  -> newDir == curDir || newDir == Northwest || newDir == Southwest
    _     -> False
