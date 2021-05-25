module View.Input exposing
    ( descriptionInput
    , endTimeInput
    , filterJobInput
    , filterTaskInput
    , hourlyRateInput
    , jobInput
    , passwordInput
    , sinceDayInput
    , startTimeInput
    , usernameInput
    )

import Element as E exposing (Element, px)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Types exposing (DataEntryMode(..), FrontendModel, FrontendMsg(..))
import View.Color as Color


inputFieldTemplate : List (E.Attribute msg) -> E.Length -> String -> (String -> msg) -> String -> Element msg
inputFieldTemplate attr width_ default msg text =
    Input.text
        ([ E.moveUp 5
         , Background.color Color.paleBlue
         , Font.color (Color.gray 0.1)
         , Font.size 16
         , E.height (px 33)
         , E.width width_
         ]
            ++ attr
        )
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        }


passwordTemplate : E.Length -> String -> (String -> msg) -> String -> Element msg
passwordTemplate width_ default msg text =
    Input.currentPassword [ E.moveUp 5, Font.size 16, E.height (px 33), E.width width_ ]
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        , show = False
        }



-- USER


usernameInput model =
    inputFieldTemplate [] (E.px 120) "Username" InputUsername model.inputUsername


passwordInput model =
    passwordTemplate (E.px 120) "Password" InputPassword model.inputPassword



-- DATA


startTimeInput model =
    inputFieldTemplate [ Background.color Color.palePink ] (E.px 100) "Start" InputStartTime model.inputStartTime


endTimeInput model =
    inputFieldTemplate [ Background.color Color.palePink ] (E.px 100) "End" InputEndTime model.inputEndTime


descriptionInput model =
    inputFieldTemplate [ editorBG model ] (panelWidth model) "Description" InputDescription model.description


editorBG model =
    case model.dataEntryMode of
        StandardDataEntry ->
            Background.color Color.paleBlue

        EditItemEntry ->
            Background.color Color.palePink


panelWidth model =
    E.px (model.windowWidth - 510)


jobInput model =
    inputFieldTemplate [ editorBG model ] (E.px 100) "Job" InputJob model.job


filterJobInput model =
    inputFieldTemplate [ Background.color Color.veryPalePink ] (E.px 100) "Filter jobs" InputJobFilter model.jobFilter


filterTaskInput model =
    inputFieldTemplate [ Background.color Color.veryPalePink ] (E.px 200) "Filter tasks" InputTaskFilter model.taskFilter


sinceDayInput model =
    inputFieldTemplate [ Background.color Color.veryPalePink ] (E.px 200) "Filter since mm/dd" InputSinceDayFilter model.sinceDayFilter


hourlyRateInput model =
    inputFieldTemplate [] (E.px 110) "Hourly rate" InputHourlyRate model.hourlyRate
