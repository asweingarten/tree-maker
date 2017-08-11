module TreeNavigation exposing (..)

import Html
import Keyboard
import Window exposing (resizes, Size)

import Model exposing (..)
import Update
import View
import Ports exposing (..)
import Time exposing (every, millisecond)
import WebSocket

import CommandPalette

{- TODO
-- Scanning
  - afford configuration of all of this
  - ScanState update should happen on Scan. Receiving regions should only set the scan cursor dimensions
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
myoWebSocketServer : String
myoWebSocketServer = "ws://localhost:8080"

myoSubscription : Sub Msg
myoSubscription = WebSocket.listen myoWebSocketServer Myo

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Keyboard.downs KeyDownMsg
  , Keyboard.downs (keyDownSubscription model)
  , Keyboard.ups KeyUpMsg
  , resizes WindowResize
  , Ports.regions Regions
  , Ports.pauseScanning (\x -> Scanning <| Pause x)
  , Ports.resumeScanning (\x -> Scanning <| Resume x)
  , Ports.toggleScanning (\x -> Scanning <| Toggle x )
  , Ports.receiveExternalCmd External -- hack
  , Ports.changePage changePage -- hack
  , Ports.hideCommandPalette HideCommandPalette
  , scanSubscription model.scan
  , myoSubscription
  , Sub.map CommandPalette (CommandPalette.subscriptions model.commandPalette)
  ]

changePage : String -> Msg
changePage pageString =
  case pageString of
    "Website" -> ChangePage Website
    "ScanningSettingsPage" -> ChangePage ScanningSettingsPage
    _ -> NoOp

keyDownSubscription : Model -> Keyboard.KeyCode -> Msg
keyDownSubscription model keycode =
  case (keycode, model.page) of
    (27, Website) -> ChangePage ScanningSettingsPage
    (27, ScanningSettingsPage) -> ChangePage Website
    (_,_) -> NoOp

scanSubscription : ScanState -> Sub Msg
scanSubscription  scan =
  case (not scan.isPaused) && (scan.settings.loops > scan.loops) of
    True  -> every (scan.settings.interval * millisecond) (\x -> Scanning <| Scan x)
    False -> Sub.none
