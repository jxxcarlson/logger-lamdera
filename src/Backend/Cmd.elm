module Backend.Cmd exposing (getRandomNumberBE, randomNumberUrl, verifyRandomAtmosphericInteger)

import Http
import Types exposing (BackendModel, BackendMsg(..))


getRandomNumberBE : Cmd BackendMsg
getRandomNumberBE =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtomsphericRandomNumberBE
        }


verifyRandomAtmosphericInteger : BackendModel -> Cmd BackendMsg
verifyRandomAtmosphericInteger model =
    case model.randomAtmosphericInt of
        Nothing ->
            getRandomNumberBE

        Just _ ->
            Cmd.none


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix
