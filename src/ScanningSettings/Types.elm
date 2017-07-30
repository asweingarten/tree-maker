module ScanningSettings.Types exposing (Model, Msg(..))

type alias Model =
  { isOn: Bool
  , interval: Float -- in milliseconds
  , loops: Int
  }

type Msg
  = Disable
  | Enable

  
