module Evergreen.V18.Authentication exposing (..)

import Dict
import Evergreen.V18.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V18.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
