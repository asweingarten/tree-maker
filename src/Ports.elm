port module Ports exposing (..)

-- Not good to redundantly define types to avoid circular deps

type alias RegionData =
  { activeRegion : Geometry
  , childRegions: List Geometry
  , siblingRegions: List Geometry
  , action: String
  }

type alias Geometry =
  { x: Int
  , y: Int
  , width: Int
  , height: Int
  }

-- Commands
port next : Int -> Cmd msg
port previous : Int -> Cmd msg
port select : Int -> Cmd msg
port up : Int -> Cmd msg

port switchTree : String -> Cmd msg
port scrollIntoView : Bool -> Cmd msg

port toggleTree : String -> Cmd msg

-- While figuring out how to elegantly subscribe to occurences in child modules,
-- going to hack around with porting out to JS and then porting back in
port startScanning : Int -> Cmd msg
port triggerToggleScanning : Int -> Cmd msg


-- Subscriptions
port regions : (RegionData -> msg) -> Sub msg

port pauseScanning : (String -> msg) -> Sub msg
port resumeScanning : (String -> msg) -> Sub msg
port toggleScanning : (String -> msg) -> Sub msg

port receiveExternalCmd : (String -> msg) -> Sub msg

port changePage : (String -> msg) -> Sub msg
port hideCommandPalette : (String -> msg) -> Sub msg
