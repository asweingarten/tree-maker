module TreeNavigation exposing (..)


import Keyboard
import Window exposing (resizes, Size)

import Model exposing (..)
import Update
import View
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
  , view = View.view
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
