module CommandPalette.State exposing (init, update)

import Mouse exposing (Position)
import Task
import Window exposing (Size)
import Debug

import CommandPalette.Types exposing (Model, CommandPalette, Msg(..), Direction(..), Square)
import CommandPalette.ChangeDirection as ChangeDirection
import CommandPalette.Dwell as Dwell
import CommandPalette.Ports as Ports
import CommandPalette.Util exposing (directionToPort)

init : (Model, Cmd Msg)
init =
  (Model
    { x = -1, y = -1 }
    (CommandPalette { x = 920, y = 500, sideLength = 115} False Nothing Nothing 3000)
    {x = 0, y = 0}
    (Size 0 0)
    (Size 0 0)
    Nothing
    False
  , Task.perform WindowResize Window.size)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PauseScanning -> (model, Cmd.none)
    CursorMoved newPosition ->
      onCursorMoved newPosition model
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
        newCommandPaletteDimensions = (Square cmdPX cmdPY cmdPSideLength)
        c = model.commandPalette
        newC = { c | dimensions = newCommandPaletteDimensions }
      in
      (
        { model
        | windowSize = wSize
        , commandPalette = newC
        }
      , Cmd.none
      )
    ScreenSize sSize ->
      ({ model | screenSize = sSize }, Cmd.none)
    SetActivationTime newTime ->
      let
        commandPalette = model.commandPalette
        newTimeFloat = case String.toFloat newTime of
          Ok time -> time
          Err _ -> commandPalette.activationTimeInMillis
      in
      ({ model | commandPalette = { commandPalette | activationTimeInMillis = newTimeFloat } }
      , Cmd.none)
    ActivateActiveCommand ->
      let
        activeCommand = model.commandPalette.activeCommand
      in
      case activeCommand of
        Just command ->
          let
            cmd = directionToPort command.direction
            cp = (\x -> { x | activeCommand = Nothing, candidateCommand = Nothing, isActive = False }) model.commandPalette
          in
          ({ model | commandPalette = cp }, cmd)
        Nothing ->
          (model, Cmd.none)

onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    cp = model.commandPalette
    threshold = cp.dimensions.sideLength
    deltaX = newPosition.x - cp.dimensions.x
    deltaY = newPosition.y - cp.dimensions.y
    (isActive, left, right, up, down) =
      -- calculated incorrectly. dominant direction should take precendence
      ( cp.isActive
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
      let commandPalette = { cp | isActive = True}
      in
      ({model | commandPalette = commandPalette }, Ports.activated "foo")
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
