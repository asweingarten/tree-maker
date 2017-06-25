port module TreeNavigation exposing (..)

import Html exposing (..)
import Keyboard
import Debug exposing (log)

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
  }

init : (Model, Cmd Msg)
init =
  (Model -1, Cmd.none)


-- UPDATE
type Msg
  = KeyMsg Keyboard.KeyCode
  | Highlight String

update : Msg -> Model -> (Model, Cmd Msg)
update msg {index} =
  case msg of
    KeyMsg code ->
      let _ = log "keycode" code
      in
      case code of
        -- Enter
        13 -> (Model index, select 1)
        9 -> (Model index, next 1)
        _ -> (Model index, Cmd.none)
    Highlight foo ->
      let _ = log "foo:" foo
      in
      (Model index, Cmd.none)

-- PORT
port next : Int -> Cmd msg
port select : Int -> Cmd msg
port highlight : (String -> msg) -> Sub msg

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyMsg
  , highlight Highlight
  ]

view : Model -> Html Msg
view model =
  div [] []
