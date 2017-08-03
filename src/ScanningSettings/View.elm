module ScanningSettings.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, type_, checked, placeholder, id, class)
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
      [ gridItem (labelledCheckbox Toggle "Scanning on?" model.isOn)
      , gridItem (incrementDecrementField SetLoops "Loops" model.loops)
      , gridItem (incrementDecrementField SetInterval "Interval" model.interval)
      ]
  in
  fullscreen "tn-settings" html

gridItem : Html msg -> Html msg
gridItem toWrap =
  let
    myStyle =
      style
        [ ("font-size", "2rem")
        , ("padding", "1.5rem")
        , ("border", "1px solid lightgray")
        , ("border-radius", "3px")
        , ("display", "flex")
        , ("justify-content", "center")
        ]
  in
  div [myStyle, class "settings-grid-item"]
    [a [] [toWrap]]

labelledCheckbox: msg -> String -> Bool -> Html msg
labelledCheckbox msg name isChecked =
  label []
    [ text name
    , input [ type_ "checkbox", onCheck (\b -> msg), checked isChecked] []
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

fullscreen: String -> Html Msg -> Html Msg
fullscreen name html =
  let
    myStyle =
      style
        [ ("position", "fixed")
        , ("width", "100%")
        , ("height", "100%")
        , ("left", "0")
        , ("top", "0")
        -- , ("z-index", "20000000001")
        , ("background-color", "white")
        , ("pointer-events", "all")
        , ("padding", "1.5rem")
        ]
  in
  div [myStyle, id name] [html]
