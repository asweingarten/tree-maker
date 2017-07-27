module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, id)

import Model exposing (..)

view : Model -> Html Msg
view {index, activeRegion, siblingRegions, childRegions}  =
  let
    activeRegionHighlight = highlight "3px solid salmon" activeRegion
    childrenHighlights = List.map (highlight "2px dashed blue") childRegions
    siblingHighlights = List.map (highlight "2px dashed green") siblingRegions
  in
  div [] ([activeRegionHighlight] ++ childrenHighlights ++ siblingHighlights)

highlight : String -> Geometry -> Html Msg
highlight borderStyle geometry =
  let
    x = toPixel geometry.x
    y = toPixel <| max geometry.y 0
    borderWidth = 3
    width = toPixel  <| geometry.width - 2*borderWidth
    height = toPixel <| geometry.height - 2*borderWidth
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", x)
        , ("top", y)
        , ("width", width)
        , ("height", height)
        , ("border", borderStyle)
        , ("border-radius", "3px")
        , ("z-index", "2000000001")
        , ("pointer-events", "none")
        ]
  in
  div [myStyle] []

toPixel : Int -> String
toPixel num =
  toString num ++ "px"
