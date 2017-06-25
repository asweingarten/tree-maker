port module TreeNavigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Keyboard
import Debug exposing (log)

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
  }

init : (Model, Cmd Msg)
init =
  (Model -1 { x = 0, y = 0, width = 0, height = 0}, Cmd.none)


-- UPDATE
type Msg
  = KeyMsg Keyboard.KeyCode
  | Highlight Geometry

update : Msg -> Model -> (Model, Cmd Msg)
update msg {index, highlightGeometry} =
  case msg of
    KeyMsg code ->
      let _ = log "keycode" code
      in
      case code of
        -- Enter
        13 -> (Model index highlightGeometry, select 1)
        9 -> (Model index highlightGeometry, next 1)
        _ -> (Model index highlightGeometry, Cmd.none)
    Highlight geometry ->
      let _ = log "geometry:" geometry
      in
      (Model index geometry, Cmd.none)

-- PORT
port next : Int -> Cmd msg
port select : Int -> Cmd msg
port highlight : (Geometry -> msg) -> Sub msg

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyMsg
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
