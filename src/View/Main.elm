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
import View.Data
import View.Dimensions as Dimensions
import View.EditData
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
        [ E.column [ E.spacing 36, E.width (E.px <| Dimensions.appWidth_ model), E.height (E.px (Dimensions.appHeight_ model)) ]
            [ header model
            , View.Utility.showIf (model.currentUser /= Nothing) (dataView model)
            , View.Utility.showIf (model.currentUser /= Nothing) (footer model)
            ]
        ]


dataView : Model -> Element FrontendMsg
dataView model =
    case model.mode of
        DefaultMode ->
            View.Data.view model

        EditMode ->
            View.EditData.view model


viewTitle model =
    case model.dataFile of
        Nothing ->
            E.el [ Font.color Color.white, Font.size 24 ] (E.text "Welcome to Logger")

        Just dataFile ->
            E.el [ Font.color Color.white, Font.size 18 ] (E.text <| dataFile.name)



-- FOOTER


footer model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (E.px <| Dimensions.appWidth_ model - 88)
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
        , View.Utility.showIfIsAdmin model (Button.toggleMode model)
        ]


viewHourlyRate model =
    case String.toFloat model.hourlyRate of
        Nothing ->
            E.none

        Just rate ->
            E.el [ Font.color Color.paleBlue ] (E.text <| String.fromFloat <| Utility.roundTo 2 <| rate * (model.totalValue / 3600.0))


footerButtons model =
    E.row [ E.width (E.px (Dimensions.panelWidth_ model)), E.spacing 12 ] []



-- HEADERS


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
    E.row [ E.spacing 24, Font.color Color.white, Font.size 16, E.width (E.px (Dimensions.appWidth_ model)) ]
        [ Button.signOut user.username
        , viewTitle model
        , viewTime model.zone model.time
        ]


viewTime : Time.Zone -> Time.Posix -> Element msg
viewTime zone time =
    E.el [ E.width (E.px 100) ]
        (E.text <| DateTimeUtility.zonedDateString zone time)


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (E.px (Dimensions.appWidth_ model + 40))
    , E.height (E.px (Dimensions.appHeight_ model + 40))
    ]


title : String -> Element msg
title str =
    E.row [ E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
