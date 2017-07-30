module ScanningSettings.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)

import ScanningSettings.Types exposing (Model, Msg(..))

view: Model -> Html Msg
view model =
  let html = (div [] [text "ay bay bay"])
  in
  fullscreen html

fullscreen: Html Msg -> Html Msg
fullscreen html =
  let
    myStyle =
      style
        [ ("display", "fixed")
        , ("width", "100%")
        , ("height", "100%")
        , ("z-index", "20000000001")
        , ("background-color", "white")
        ]
  in
  div [myStyle] [html]
