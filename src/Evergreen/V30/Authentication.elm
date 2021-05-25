module Evergreen.V30.Authentication exposing (..)

import Dict
import Evergreen.V30.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V30.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
