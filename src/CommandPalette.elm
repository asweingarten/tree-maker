module CommandPalette exposing (Model, Msg, init, update, subscriptions, view)

import CommandPalette.Types as Types
import CommandPalette.State as State
import CommandPalette.Subscriptions as Subscriptions
import CommandPalette.View as View

type alias Model = Types.Model
type alias Msg = Types.Msg

init : (Model, Cmd Msg)
init = State.init

update = State.update

subscriptions = Subscriptions.subscriptions

view = View.view
