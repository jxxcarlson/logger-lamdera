module View.Data exposing (view)

import Calendar
import Data.Data as Data
import DateTime exposing (DateTime)
import DateTimeUtility
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Time
import Types exposing (..)
import Utility
import View.Button as Button
import View.Color as Color
import View.Dimensions exposing (appHeight_, appWidth_, panelWidth_)
import View.Input
import View.Popup
import View.Style
import View.Utility


view model =
    E.column [ E.spacing 24, E.width (E.px <| appWidth_ model) ]
        [ E.column [ E.spacing 8 ]
            [ logItem_ model
            , View.Utility.showIf (model.currentUser /= Nothing) (messageRow model)
            ]
        , viewData model
        ]


viewData model =
    E.column [ E.spacing 8 ]
        [ dataHeader model
        , viewData_ model
        , summary model
        ]


viewData_ model =
    case model.dataFile of
        Nothing ->
            E.column
                [ E.spacing 8
                , E.paddingXY 12 12
                , E.height (E.px (model.windowHeight - 430))
                , E.width (E.px (model.windowWidth - 232))
                , Background.color Color.paleBlue
                , Font.size 16
                , E.scrollbarY
                ]
                [ E.text "Sorry, no data file" ]

        Just dataFile ->
            E.column
                [ E.spacing 8
                , E.paddingXY 12 12
                , E.height (E.px (model.windowHeight - 430))
                , E.width (E.px (model.windowWidth - 232))
                , Background.color Color.paleBlue
                , Font.size 16
                ]
                (List.map (Data.view model.zone) (Data.filterData model.time model.jobFilter model.taskFilter model.sinceDayFilter dataFile.data))


logItem_ model =
    E.column [ E.spacing 8 ]
        [ logItem model
        , E.row [ E.spacing 8 ]
            [ Button.saveItem
            , View.Input.jobInput model
            , View.Input.descriptionInput model
            ]
        ]


logItem model =
    E.row [ E.spacing 8, Font.size 16, Font.color Color.white ]
        [ E.row [ E.spacing 8 ] [ Button.setStartTime, viewStartTime model ]
        , E.row [ E.spacing 8 ] [ Button.setEndTime, viewEndTime model ]
        , viewElapsedTime model
        , E.row [ E.spacing 8, E.paddingEach { left = 48, right = 0, top = 0, bottom = 0 } ]
            [ View.Input.filterJobInput model
            , View.Input.filterTaskInput model
            , View.Input.sinceDayInput model
            ]
        ]


viewStartTime model =
    let
        label =
            case model.startTime of
                Nothing ->
                    "(not started)"

                Just time ->
                    DateTimeUtility.zonedTimeString model.zone time
    in
    E.el [ E.width (E.px 100) ] (E.el [ E.centerX ] (E.text label))


viewEndTime model =
    let
        label =
            case model.endTime of
                Nothing ->
                    "(not finished)"

                Just time ->
                    DateTimeUtility.zonedTimeString model.zone time
    in
    E.el [ E.width (E.px 100) ] (E.el [ E.centerX ] (E.text label))


viewElapsedTime model =
    case ( model.startTime, model.endTime ) of
        ( Just start, Just end ) ->
            E.el [] (E.text <| "Elapsed: " ++ DateTimeUtility.elapsedTimeAsString start end)

        _ ->
            E.none


dataHeader model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 30)
        , E.width (E.px <| appWidth_ model - 89)
        , Font.size 14
        , Background.color Color.paleBlue
        , E.paddingXY 8 8
        , Font.bold
        ]
        [ Data.heading Data.TTask ]


summary model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 30)
        , E.width (E.px <| appWidth_ model - 89)
        , Font.size 14
        , Background.color Color.paleBlue
        , E.paddingXY 8 8
        ]
        [ E.el [ Font.bold ] (E.text <| "Total hours: " ++ String.fromFloat (Utility.roundTo 2 <| Data.totalValue model.filteredData / 3600.0)) ]


messageRow model =
    E.row
        [ E.width E.fill
        , E.height (E.px 30)
        , E.paddingXY 8 4
        , View.Style.bgGray 0.21
        , Font.color Color.paleBlue -- View.Style.fgGray 0.8
        , Font.size 16
        ]
        [ E.text model.message ]
