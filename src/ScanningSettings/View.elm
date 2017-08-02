module ScanningSettings.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, type_, checked, placeholder)
import Html.Events exposing (onCheck, onInput)

import Json.Decode exposing (decodeString, int)

import ScanningSettings.Types exposing (Model, Msg(..))

view: Model -> Html Msg
view model =
  let
    myStyle =
      style
        [ ("display", "grid")
        , ("grid-template-columns", "repeat(3, 1fr)")
        , ("grid-column-gap", "1rem")
        , ("grid-row-gap", "1rem")
        ]

    html = div [myStyle]
      [ div [] [labelledCheckbox Toggle "Scanning on?" model.isOn]
      , div [] [incrementDecrementField SetLoops "Loops" model.loops]
      , div [] [incrementDecrementField SetInterval "Interval" model.interval]
      ]
  in
  fullscreen html

labelledCheckbox: msg -> String -> Bool -> Html msg
labelledCheckbox msg name isChecked =
  label []
    [ input [ type_ "checkbox", onCheck (\b -> msg), checked isChecked] []
    , text name
    ]

incrementDecrementField: (Result String Int -> msg) -> String -> number -> Html msg
incrementDecrementField msg name currentValue =
  label []
    [ input [ type_ "number"
            , onInput (\s -> msg (decodeString int s) )
            , placeholder (toString currentValue)
            ] []
    , text name
    ]

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
