module ScanningSettings exposing (Model, Msg, init, update)

import ScanningSettings.Types as Types
import ScanningSettings.State as State

type alias Model = Types.Model
type alias Msg = Types.Msg

init : (Model, Cmd Msg)
init = State.init

update = State.update
