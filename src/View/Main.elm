module View.Main exposing (view)

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
import View.Input
import View.Popup
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.9, E.clipX, E.clipY ]
        (mainColumn model)


mainColumn : Model -> Element FrontendMsg
mainColumn model =
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 36, E.width (E.px <| appWidth_ model), E.height (E.px (appHeight_ model)) ]
            [ header model
            , View.Utility.showIf (model.currentUser /= Nothing) (body model)
            , View.Utility.showIf (model.currentUser /= Nothing) (footer model)
            ]
        ]


viewTitle model =
    case model.dataFile of
        Nothing ->
            E.el [ Font.color Color.white, Font.size 24 ] (E.text "Welcome to Logger")

        Just dataFile ->
            E.el [ Font.color Color.white, Font.size 18 ] (E.text <| dataFile.name)


body model =
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


footer model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (E.px <| appWidth_ model - 88)
        , Font.size 14
        , E.inFront (View.Popup.admin model)
        ]
        [ Button.adminPopup model
        , View.Utility.showIfIsAdmin model Button.runTask
        , Button.exportTimesheet
        , Button.exportData
        , Button.importData
        , View.Utility.showIfIsAdmin model (View.Input.hourlyRateInput model)
        , View.Utility.showIfIsAdmin model (viewHourlyRate model)
        ]


viewHourlyRate model =
    case String.toFloat model.hourlyRate of
        Nothing ->
            E.none

        Just rate ->
            E.el [ Font.color Color.paleBlue ] (E.text <| String.fromFloat <| Utility.roundTo 2 <| rate * (model.totalValue / 3600.0))


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


footerButtons model =
    E.row [ E.width (E.px (panelWidth_ model)), E.spacing 12 ] []


header model =
    case model.currentUser of
        Nothing ->
            notSignedInHeader model

        Just user ->
            signedInHeader model user


notSignedInHeader model =
    E.column [ E.spacing 24 ]
        [ viewTitle model
        , E.row
            [ E.spacing 12
            , Font.size 14
            ]
            [ Button.signIn
            , View.Input.usernameInput model
            , View.Input.passwordInput model
            , E.el [ E.height (E.px 31), E.paddingXY 12 3, Background.color Color.paleBlue ]
                (E.el [ E.centerY ] (E.text model.message))
            ]
        ]


signedInHeader model user =
    E.row [ E.spacing 24, Font.color Color.white, Font.size 16, E.width (E.px (appWidth_ model)) ]
        [ Button.signOut user.username
        , viewTitle model
        , viewTime model.zone model.time
        ]


viewTime : Time.Zone -> Time.Posix -> Element msg
viewTime zone time =
    E.el [ E.width (E.px 100) ]
        (E.text <| DateTimeUtility.zonedDateString zone time)



-- DIMENSIONS


panelWidth_ model =
    min 600 ((model.windowWidth - 100 - docListWidth) // 2)


docListWidth =
    220


appHeight_ model =
    model.windowHeight - 100


panelHeight_ model =
    appHeight_ model - 110


appWidth_ model =
    2 * panelWidth_ model + docListWidth + 15


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (E.px (appWidth_ model + 40))
    , E.height (E.px (appHeight_ model + 40))
    ]


title : String -> Element msg
title str =
    E.row [ E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
