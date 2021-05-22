module View.Input exposing
    ( descriptionInput
    , filterJobInput
    , filterTaskInput
    , jobInput
    , passwordInput
    , usernameInput
    )

import Element as E exposing (Element, px)
import Element.Font as Font
import Element.Input as Input
import Types exposing (FrontendModel, FrontendMsg(..))


inputFieldTemplate : E.Length -> String -> (String -> msg) -> String -> Element msg
inputFieldTemplate width_ default msg text =
    Input.text [ E.moveUp 5, Font.size 16, E.height (px 33), E.width width_ ]
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
    inputFieldTemplate (E.px 120) "Username" InputUsername model.inputUsername


passwordInput model =
    passwordTemplate (E.px 120) "Password" InputPassword model.inputPassword



-- DATA


startTimeInput model =
    inputFieldTemplate (E.px 120) "Start" InputStartTime model.inputStartTime


endTimeInput model =
    inputFieldTemplate (E.px 120) "End" InputEndTime model.inputEndTime


descriptionInput model =
    inputFieldTemplate (E.px (model.windowWidth - 448)) "Description" InputDescription model.description


jobInput model =
    inputFieldTemplate (E.px 100) "Job" InputJob model.job


filterJobInput model =
    inputFieldTemplate (E.px 100) "Filter jobs" InputJobFilter model.jobFilter


filterTaskInput model =
    inputFieldTemplate (E.px 200) "Filter tasks" InputTaskFilter model.taskFilter
