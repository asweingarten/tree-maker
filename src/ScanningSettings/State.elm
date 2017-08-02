module ScanningSettings.State exposing (init, update)

import ScanningSettings.Types exposing (Model, Msg(..))

init : (Model, Cmd Msg)
init =
  (Model False 2000 2, Cmd.none)

update : Model -> Msg -> (Model, Cmd Msg)
update model msg =
  case msg of
    Enable ->
      ({ model | isOn = True }, Cmd.none)
    Disable ->
      ({ model | isOn = False }, Cmd.none)
    Toggle ->
      ({ model | isOn = not model.isOn }, Cmd.none)
    SetLoops numLoopsResult ->
      case numLoopsResult of
        Err err -> (model, Cmd.none)
        Ok value ->
          ({ model | loops = value }, Cmd.none)
    SetInterval intervalResult ->
      case intervalResult of
        Err err -> (model, Cmd.none)
        Ok value -> ({ model | interval = toFloat value }, Cmd.none)
