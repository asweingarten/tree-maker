port module TreeNavigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Keyboard
import Debug exposing (log)

-- TODO
-- Pack up into chrome extension so can test on various websites
-- Highlight the child chunks that will become available (use dotted border)
-- Click the children
-- How handle things that weren't there originally? e.g. modal windows (think Youtube unsubscribe)


main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

type alias Geometry =
  { x: Int
  , y: Int
  , width: Int
  , height: Int
  }

-- MODEL
type alias Model =
  { index : Int
  , highlightGeometry: Geometry
  , isShiftDown : Bool
  }

init : (Model, Cmd Msg)
init =
  (Model -1 { x = 0, y = 0, width = 0, height = 0} False, Cmd.none)


-- UPDATE
type Msg
  = KeyDownMsg Keyboard.KeyCode
  | KeyUpMsg Keyboard.KeyCode
  | Highlight Geometry

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyDownMsg code ->
      let _ = log "keycode" code
      in
      case code of
        -- Enter
        13 -> (model, select 1)
        -- If shift is down, then make sure you do the right thing
        9 -> (model, next 1)
        16 -> ({ model | isShiftDown = True }, Cmd.none)
        _ -> (model, Cmd.none)
    KeyUpMsg code ->
      case code of
        16 -> ({ model | isShiftDown = False }, Cmd.none)
        _ -> (model, Cmd.none)
    Highlight geometry ->
      let _ = log "geometry:" geometry
      in
      ({ model | highlightGeometry = geometry }, Cmd.none)

-- PORT
port next : Int -> Cmd msg
port select : Int -> Cmd msg
port highlight : (Geometry -> msg) -> Sub msg

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyDownMsg
  , Keyboard.ups KeyUpMsg
  , highlight Highlight
  ]

view : Model -> Html Msg
view {index, highlightGeometry}  =
  let
    x = toString highlightGeometry.x ++ "px"
    y = toString highlightGeometry.y ++ "px"
    width = toString highlightGeometry.width ++ "px"
    height = toString highlightGeometry.height ++ "px"
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", x)
        , ("top", y)
        , ("width", width)
        , ("height", height)
        , ("border", "3px solid salmon")
        , ("border-radius", "3px")
        ]
  in
  div [myStyle] []
