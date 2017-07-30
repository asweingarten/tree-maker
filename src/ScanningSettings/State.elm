module ScanningSettings.State exposing (init, update)

import ScanningSettings.Types exposing (Model, Msg(..))

init : (Model, Cmd Msg)
init =
  (Model False 2000 2, Cmd.none)

update : Model -> Msg -> (Model, Cmd Msg)
update model msg =
  case msg of
    Enable -> ({ model | isOn = True }, Cmd.none)
    Disable -> ({ model | isOn = False }, Cmd.none)
