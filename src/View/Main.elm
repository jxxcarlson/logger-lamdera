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
        [ logItem_ model
        , case model.dataFile of
            Nothing ->
                E.column
                    [ E.spacing 8
                    , E.paddingXY 12 12
                    , E.height (E.px (model.windowHeight - 430))
                    , E.width (E.px (model.windowWidth - 232))
                    , Background.color Color.paleBlue
                    , Font.size 16
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
                    (List.map (Data.view model.zone) dataFile.data)
        ]


logItem_ model =
    E.column [ E.spacing 8 ]
        [ logItem model
        , E.row [ E.spacing 8 ] [ Button.saveItem, View.Input.jobInput model, View.Input.descriptionInput model ]
        ]


logItem model =
    E.row [ E.spacing 8, Font.size 16, Font.color Color.white ]
        [ E.row [ E.spacing 8 ] [ Button.setStartTime, viewStartTime model ]
        , E.row [ E.spacing 8 ] [ Button.setEndTime, viewEndTime model ]
        , viewElapsedTime model
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
        , messageRow model
        ]


messageRow model =
    E.row
        [ E.width E.fill
        , E.height (E.px 30)
        , E.paddingXY 8 4
        , View.Style.bgGray 0.1
        , View.Style.fgGray 1.0
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


docsInfo model n =
    let
        total =
            List.length model.documents
    in
    E.el
        [ E.height (E.px 30)
        , E.width (E.px docListWidth)
        , Font.size 16
        , E.paddingXY 12 7
        , Background.color Color.paleViolet
        , Font.color Color.lightBlue
        ]
        (E.text <| "filtered/fetched = " ++ String.fromInt n ++ "/" ++ String.fromInt total)


docList_ : Model -> List (Element FrontendMsg) -> Element FrontendMsg
docList_ model filteredDocs =
    E.column
        [ View.Style.bgGray 0.85
        , E.height (E.px (panelHeight_ model - searchDocPaneHeight))
        , E.spacing 4
        , E.width (E.px docListWidth)
        , E.paddingXY 8 12
        , Background.color Color.paleViolet
        , E.scrollbarY
        ]
        filteredDocs


viewDummy : Model -> Element FrontendMsg
viewDummy model =
    E.column
        [ E.paddingEach { left = 24, right = 24, top = 12, bottom = 96 }
        , Background.color Color.veryPaleBlue
        , E.width (E.px (panelWidth_ model))
        , E.height (E.px (panelHeight_ model))
        , E.centerX
        , Font.size 14
        , E.alignTop
        ]
        []



-- DIMENSIONS


searchDocPaneHeight =
    70


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
