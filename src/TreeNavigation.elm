module TreeNavigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, id)
import Keyboard
import Window exposing (resizes, Size)

import Model exposing (..)
import Update
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
  { init = Model.init
  , view = view
  , update = Update.update
  , subscriptions = subscriptions
  }


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyDownMsg
  , Keyboard.ups KeyUpMsg
  , resizes WindowResize
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
