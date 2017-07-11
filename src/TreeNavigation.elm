module TreeNavigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, id)
import Keyboard
import Debug exposing (log)

import Types exposing(Geometry)
import Ports exposing (..)

-- TODO
-- Highlight the child chunks that will become available (use dotted border)
-- How handle things that weren't there originally? e.g. modal windows (think Youtube unsubscribe)
  -- on click, check out dem DOM mutation events
-- How handle things that go offscreen?
-- Scroll to region
-- Ignore elements that are 0 height.... though sometimes this is too general.....
-- On DOM mutation, update tree....
    -- handling modals
    -- single page app page transitions
-- State machine of what happens on DOM mutations?
-- Error recovery, refresh the page on error
-- if children are bigger than the top-level div, then it's misleading...
  -- e.g. https://stackoverflow.com/questions/8967902/why-do-you-need-to-put-bin-bash-at-the-beginning-of-a-script-file
  --      there are two containing divs and only one of them is the right size. Maybe should remove redundant
  --      divs AFTER tree creation and pick the bigger one?

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
  | External String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyDownMsg code ->
      let _ = log "keycode" code
      in
      case (code, model.isShiftDown) of
        -- Enter
        (13, _) -> (model, Ports.select 1)
        -- If shift is down, then make sure you do the right thing
        (9, False) -> (model, Ports.next 1)
        (9, True) -> (model, Ports.up 1)
        (16, _) -> ({ model | isShiftDown = True }, Cmd.none)
        _ -> (model, Cmd.none)
    KeyUpMsg code ->
      case code of
        16 -> ({ model | isShiftDown = False }, Cmd.none)
        _ -> (model, Cmd.none)
    Highlight geometry ->
      let _ = log "geometry:" geometry
      in
      ({ model | highlightGeometry = geometry }, Cmd.none)
    External cmdString ->
      let
        cmd =
          case cmdString of
            "Up" -> Ports.up 1
            "Select" -> Ports.select 1
            "Next" -> Ports.next 1
            _ -> Cmd.none
      in
      (model, cmd)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyDownMsg
  , Keyboard.ups KeyUpMsg
  , Ports.highlight Highlight
  , Ports.receiveExternalCmd External
  ]

view : Model -> Html Msg
view {index, highlightGeometry}  =
  let
    x = toPixel highlightGeometry.x
    y = toPixel <| max highlightGeometry.y 0
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
        , ("pointer-events", "none")
        ]
  in
  div [myStyle, id "my-highlight"] []

toPixel : Int -> String
toPixel num =
  toString num ++ "px"
