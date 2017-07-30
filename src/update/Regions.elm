module Regions exposing (..)

import Window exposing (Size)
import Debug exposing (log)

import Model exposing (..)
import Ports
import ScanState

update: Model -> RegionData -> (Model, Cmd Msg)
update model regionData =
  let
    cmd = scrollCommand regionData.activeRegion model.viewportSize
    -- newScanState =
    --   case model.scanningSettings.isOn of
    --     True -> ScanState.update model.scan regionData
    --     False -> model.scan
  in
  ({ model
  | activeRegion   = regionData.activeRegion
  , childRegions   = regionData.childRegions
  , siblingRegions = regionData.siblingRegions
  -- , scan           = newScanState
  }
  , cmd)

scrollCommand : Geometry -> Size -> Cmd Msg
scrollCommand geometry viewportSize =
  let
    isTall = geometry.height > viewportSize.height
    _ = log "isTall" isTall
    isInViewport = isElementInViewport geometry viewportSize isTall
    _ = log "isInViewport" isInViewport
  in
  case isInViewport of
    True -> Cmd.none
    False -> Ports.scrollIntoView isTall

isElementInViewport : Geometry -> Size -> Bool -> Bool
isElementInViewport geometry size isTall =
  case isTall of
    True ->
      let x = ( (geometry.y) + (round ( (toFloat (geometry.height)) / 4) ) )
      in
      geometry.y >= 0
      && (geometry.x >= 0)
      && (size.height >= x)
    False ->
      geometry.y >= 0
      && (geometry.x >= 0)
      && ((geometry.y + geometry.height) <= size.height)
      && (geometry.x + geometry.width <= size.width)
-- if (!isElementInViewport(currentDomElement)) {
--   const rect = currentDomElement.getBoundingClientRect();
--   const isTall = rect.height > window.innerHeight;
--   currentDomElement.scrollIntoView(isTall);
--   if (isTall) window.scrollBy(0, -3);
--
-- }

-- function isElementInViewport (el) {
--
--   //special bonus for those using jQuery
--   if (typeof jQuery === "function" && el instanceof jQuery) {
--     el = el[0];
--   }
--
--   var rect = el.getBoundingClientRect();
--
--   // handle tall elements differently than short elements
--   //  tall := taller than window.innerHeight, short := not tall
--   if (rect.height >= window.innerHeight) {
--     return (
--       rect.top >= 0 &&
--       rect.left >= 0 &&
--       rect.top + rect.height/4 < window.innerHeight
--     );
--   } else {
--     return (
--       rect.top >= 0 &&
--       rect.left >= 0 &&
--       rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) && /*or $(window).height() */
--       rect.right <= (window.innerWidth || document.documentElement.clientWidth) /*or $(window).width() */
--     );
--   }
-- }
