module View.Button exposing
    ( adminPopup
    , exportData
    , exportTimesheet
    , getUsers
    , importData
    , linkTemplate
    , runTask
    , saveItem
    , setEndTime
    , setStartTime
    , signIn
    , signOut
    , test
    )

import Config
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Types exposing (..)
import View.Color as Color
import View.Style
import View.Utility



-- TEMPLATES


buttonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


microButtonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
microButtonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


linkTemplate : msg -> E.Color -> String -> Element msg
linkTemplate msg fontColor label_ =
    E.row [ E.pointer, E.mouseDown [ Background.color Color.paleBlue ] ]
        [ Input.button linkStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14, Font.color fontColor ] (E.text label_)
            }
        ]


linkStyle =
    [ Font.color (E.rgb255 255 255 255)
    , E.paddingXY 8 2
    ]



-- USER


signOut username =
    buttonTemplate [] SignOut username



-- USER


signIn : Element FrontendMsg
signIn =
    buttonTemplate [] SignIn "Sign in | Sign up"



-- ADMIN


runTask : Element FrontendMsg
runTask =
    buttonTemplate [] AdminRunTask "Run Task"


adminPopup : FrontendModel -> Element FrontendMsg
adminPopup model =
    let
        nextState : PopupStatus
        nextState =
            case model.popupStatus of
                PopupClosed ->
                    PopupOpen AdminPopup

                PopupOpen AdminPopup ->
                    PopupClosed

        isVisible =
            Maybe.map .username model.currentUser == Just Config.administrator
    in
    View.Utility.showIf isVisible <| buttonTemplate [] (ChangePopupStatus nextState) "Admin"


getUsers =
    buttonTemplate [] GetUsers "Get Users"



-- LOG


setStartTime =
    buttonTemplate [ E.width (E.px 100) ] SetStartTime "Start task"


setEndTime =
    buttonTemplate [ E.width (E.px 100) ] SetEndTime "End task"


saveItem model =
    case model.dataEntryMode of
        StandardDataEntry ->
            buttonTemplate [ E.width (E.px 100) ] SaveItem "Save"

        EditItemEntry ->
            buttonTemplate [ E.width (E.px 100), Font.color Color.palePink, Background.color Color.darkPink ] SaveItem "Save Edit"


exportTimesheet =
    buttonTemplate [ E.width (E.px 140) ] ExportTimeSheet "Export timesheet"


exportData =
    buttonTemplate [ E.width (E.px 120) ] ExportData "Export data"


importData =
    buttonTemplate [] CsvRequested "Import data"


test model =
    buttonTemplate [] Test "Test"
