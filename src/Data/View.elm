module Data.View exposing (..)

import Data.Data exposing (Data(..), DataType(..))
import DateTimeUtility
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Time
import Types exposing (FrontendMsg(..))
import View.Color as Color
import View.Style


heading : DataType -> Element FrontendMsg
heading dataType =
    let
        nudge =
            E.moveRight 4
    in
    case dataType of
        TTask ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100), nudge ] (E.text "Job")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "Date")
                , E.el [ E.width (E.px 50), nudge ] (E.text <| "Start")
                , E.el [ E.width (E.px 44), nudge ] (E.text <| "End")
                , E.el [ E.width (E.px 70), nudge ] (E.text <| "Elapsed")
                , E.el [ E.width (E.px 500), nudge ] (E.text <| "Description")
                ]

        TQuantity ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100), nudge ] (E.text <| "Start")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "End")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "Value")
                , E.el [ E.width (E.px 500), nudge ] (E.text <| "Description")
                ]


editItem datum =
    buttonTemplate
        [ E.width (E.px 20)
        , E.height (E.px 20)
        , Background.color Color.lightBlue2
        , Font.color Color.palePink
        ]
        (EditItem datum)
        ""


buttonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


view : Time.Zone -> Data -> Element FrontendMsg
view zone data =
    case data of
        (Task { id, start, end, desc, job }) as datum ->
            E.row [ E.spacing 8 ]
                [ editItem datum
                , E.el [ E.width (E.px 100) ] (E.text job)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedDateString zone end)
                , E.el [ E.width (E.px 50) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 44) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 70) ] (E.text <| DateTimeUtility.elapsedTimeAsString start end)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]

        Quantity { start, end, value, desc } ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 100) ] (E.text <| String.fromFloat value)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]
