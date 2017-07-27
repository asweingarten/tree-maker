module ScanState exposing (..)

import Model exposing (..)

update : ScanState -> RegionData -> ScanState
update scanState regionData =
  case toAction regionData.action of
    Select ->
      { loops = 0
      , scanIndex = 0
      , elementsToScan = 1 + List.length regionData.siblingRegions
      }
    Next ->
      case (scanState.scanIndex + 1) == scanState.elementsToScan of
        True ->
          { scanState
          | loops = scanState.loops + 1
          , scanIndex = 0
          }
        False ->
          { scanState
          | scanIndex = scanState.scanIndex + 1
          }
    Previous ->
      case (scanState.scanIndex == 0) of
        True ->
          { scanState
          | loops = scanState.loops + 1
          , scanIndex = scanState.elementsToScan - 1
          }
        False ->
          { scanState
          | scanIndex = scanState.scanIndex - 1
          }
    Up ->
      { loops = 0
      , scanIndex = 0
      , elementsToScan = 1 + List.length regionData.siblingRegions
      }
    Noop -> scanState


toAction : String -> Action
toAction string =
  case string of
    "UP" -> Up
    "SELECT" -> Select
    "PREVIOUS" -> Previous
    "NEXT" -> Next
    _ -> Noop
