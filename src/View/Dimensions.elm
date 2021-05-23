module View.Dimensions exposing (appHeight_, appWidth_, panelWidth_)

import Types exposing (..)


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
