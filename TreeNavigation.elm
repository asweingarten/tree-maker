module TreeNavigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, id)
import Keyboard
import Debug exposing (log)

import Types exposing(Geometry)
import Ports exposing (..)

-- TODO
-- Highlight the child chunks that will become available (use dotted border)
-- Click the children
-- How handle things that weren't there originally? e.g. modal windows (think Youtube unsubscribe)
-- How handle things that go offscreen?
-- Scroll to region
-- Ignore elements that are 0 height


main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
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
        13 -> (model, Ports.select 1)
        -- If shift is down, then make sure you do the right thing
        9 -> (model, Ports.next 1)
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

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyDownMsg
  , Keyboard.ups KeyUpMsg
  , Ports.highlight Highlight
  ]

view : Model -> Html Msg
view {index, highlightGeometry}  =
  let
    x = toPixel highlightGeometry.x
    y = toPixel highlightGeometry.y
    borderWidth = 3
    width = toPixel  <| highlightGeometry.width - 2*borderWidth
    height = toPixel <| highlightGeometry.height - 2*borderWidth
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", x)
        , ("top", y)
        , ("width", width)
        , ("height", height)
        , ("border", "3px solid salmon")
        , ("border-radius", "3px")
        , ("z-index", "2000000001")
        ]
  in
  div [myStyle, id "my-highlight"] []

toPixel : Int -> String
toPixel num =
  toString num ++ "px"
