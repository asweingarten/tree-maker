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
-- PORT
port next : Int -> Cmd msg
port previous : Int -> Cmd msg
port select : Int -> Cmd msg
port up : Int -> Cmd msg

port scrollIntoView : Bool -> Cmd msg

port regions : (RegionData -> msg) -> Sub msg
port pauseScanning : (String -> msg) -> Sub msg
port resumeScanning : (String -> msg) -> Sub msg

port switchTree : String -> Cmd msg

port receiveExternalCmd : (String -> msg) -> Sub msg
