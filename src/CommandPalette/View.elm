module CommandPalette.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)

import CommandPalette.Types exposing (CommandPalette, Msg(..))

import CommandPalette.ProgressBar as ProgressBar

view : CommandPalette -> Html Msg
view {dimensions, isActive, activeCommand, candidateCommand, activationTimeInMillis} =
  let
    x = dimensions.x
    y = dimensions.y
    sideLength = dimensions.sideLength
    left = toPixels (x - sideLength)
    top = toPixels (y - sideLength)
    len = toPixels (sideLength * 2)
    color = case isActive of
      True ->
        "rgba(25,25,75,0.5)"
      False ->
        "rgba(25,25,75,0.2)"
    progressBar =
      case activeCommand of
        Nothing -> div [] []
        Just command -> ProgressBar.view command
    candidateBar =
      case candidateCommand of
        Nothing -> div [] []
        Just command -> ProgressBar.view command
    fullscreenStyle =
      style
        [ ("position", "absolute")
        , ("width", "100%")
        , ("height", "100%")
        , ("left", "0")
        , ("top", "0")
        ]
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", left)
        , ("top", top)
        , ("width", len)
        , ("height", len)
        , ("background-color", color)
        ]
    westStyle = commandTextStyle (x - sideLength - 160) (y - 12)
    northStyle = commandTextStyle (x - 24) (y - sideLength - 80)
    eastStyle = commandTextStyle (x + sideLength + 10) (y - 12)
    southStyle = commandTextStyle (x - 48) (y + sideLength + 10)
  in
  div []
    [ div [myStyle] []
    , progressBar
    , candidateBar
    , div [westStyle] [text "Menu"]
    , div [northStyle] [text "Up"]
    , div [eastStyle] [text "Scan"]
    , div [southStyle] [text "Select"]
    ]

commandTextStyle : Int -> Int -> Attribute Msg
commandTextStyle left top =
  style
    [ ("position", "fixed")
    , ("left", toPixels left)
    , ("top", toPixels top)
    , ("font-size", "3rem")
    , ("border-radius", "3px")
    , ("background-color", "rgba(240, 240, 240, 0.9)")
    , ("padding", "0 10px")
    ]

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
