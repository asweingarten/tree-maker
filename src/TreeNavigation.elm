module TreeNavigation exposing (..)

import Html
import Keyboard
import Window exposing (resizes, Size)

import Model exposing (..)
import Update
import View
import Ports exposing (..)
import Time exposing (every, millisecond)

{- TODO
-- Scanning
  - set loop timeout
    - keep track of how many scans makes up a loop
  - stop scanning while entering a command
  - afford configuration of all of this
-- Ignore own DOM mutations
-- Error recovery, refresh the page on error


-- if children are bigger than the top-level div, then it's misleading...
  -- e.g. https://stackoverflow.com/questions/8967902/why-do-you-need-to-put-bin-bash-at-the-beginning-of-a-script-file
  --      there are two containing divs and only one of them is the right size. Maybe should remove redundant
  --      divs AFTER tree creation and pick the bigger one?
-}
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
  , Ports.regions Regions
  , Ports.receiveExternalCmd External
  , scanSubscription model.scanningSettings model.scanState
  ]

scanSubscription : ScanningSettings -> ScanState -> Sub Msg
scanSubscription settings scanState =
  case settings.isOn && (settings.loops > scanState.loops) of
    True  -> every (settings.interval * millisecond) Scan
    False -> Sub.none
