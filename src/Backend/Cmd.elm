module Backend.Cmd exposing (getRandomNumberBE, randomNumberUrl)

import Http
import Types exposing (BackendMsg(..))


getRandomNumberBE : Cmd BackendMsg
getRandomNumberBE =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtomsphericRandomNumberBE
        }


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
