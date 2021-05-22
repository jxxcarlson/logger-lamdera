module View.Color exposing
    ( black
    , blue
    , darkBlue
    , darkRed
    , gray
    , lessPaleBlue
    , lightBlue
    , lightGray
    , medGray
    , paleBlue
    , palePink
    , paleViolet
    , red
    , transparentBlue
    , veryPaleBlue
    , white
    )

import Element as E


white : E.Color
white =
    E.rgb 255 255 255


lightGray : E.Color
lightGray =
    gray 0.9


medGray : E.Color
medGray =
    gray 0.5


black : E.Color
black =
    E.rgb 20 20 20


palePink =
    E.rgb255 250 210 243


red : E.Color
red =
    E.rgb255 255 0 0


darkRed : E.Color
darkRed =
    E.rgb255 140 0 0


blue : E.Color
blue =
    E.rgb255 0 0 140


darkBlue : E.Color
darkBlue =
    E.rgb255 0 0 120


lightBlue : E.Color
lightBlue =
    E.rgb255 120 120 200


paleBlue : E.Color
paleBlue =
    E.rgb255 220 220 240


lessPaleBlue : E.Color
lessPaleBlue =
    E.rgb255 220 210 255


veryPaleBlue : E.Color
veryPaleBlue =
    E.rgb255 140 140 150


transparentBlue : E.Color
transparentBlue =
    E.rgba 0.9 0.9 1 0.9


paleViolet : E.Color
paleViolet =
    E.rgb255 230 230 255


gray : Float -> E.Color
gray g =
    E.rgb g g g
