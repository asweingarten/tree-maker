module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, id)
import Html.Events exposing (onMouseEnter)

import Model exposing (..)
import ScanningSettings
import CommandPalette

view : Model -> Html Msg
view model  =
  let
    activeRegionHighlight = highlight "3px solid orangered" model.activeRegion
    -- childrenHighlights = List.map (highlight "2px dashed lightsteelblue") childRegions
    -- siblingHighlights = List.map (highlight "2px dashed mediumaquamarine") model.siblingRegions
    (commandPalette, cpTrigger) =
      case model.showCommandPalette of
        True -> (CommandPalette.view model.commandPalette |> Html.map CommandPalette, div [] [])
        False -> (div [] [], commandPaletteTrigger)
  in
  div [id "tree-nav-screen"]
    [ div [id "highlights"] ([activeRegionHighlight] )
    , page model
    , commandPalette
    , cpTrigger
    ]

commandPaletteTrigger : Html Msg
commandPaletteTrigger =
  let
    myStyle =
      style
        [ ("position", "fixed")
        , ("right", "0")
        , ("bottom", "0")
        , ("width", "13%")
        , ("height", "20%")
        , ("background-color", "rgba(40, 40, 40, 0.7)")
        , ("border", "3px solid rgba(230, 230, 230, 0.7)")
        , ("border-radius", "3px")
        , ("pointer-events", "all")
        , ("text-align", "center")
        , ("display", "flex")
        , ("align-items", "center")
        , ("justify-content", "center")
        , ("font-size", "1.5rem")
        ]
  in
  div [myStyle, onMouseEnter ToggleCommandPalette] [div [] [text "Actions"] ]

page : Model -> Html Msg
page model =
  case model.page of
    Website ->
      div [] []
    ScanningSettingsPage ->
      ScanningSettings.view model.scanningSettings |> Html.map ScanningSettings


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
