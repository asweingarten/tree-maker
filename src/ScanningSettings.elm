module ScanningSettings exposing (Model, Msg, init, update, view)

import ScanningSettings.Types as Types
import ScanningSettings.State as State
import ScanningSettings.View as View

type alias Model = Types.Model
type alias Msg = Types.Msg

init : (Model, Cmd Msg)
init = State.init

update = State.update

view = View.view
