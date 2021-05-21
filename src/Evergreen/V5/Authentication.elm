module Evergreen.V5.Authentication exposing (..)

import Dict
import Evergreen.V5.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V5.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
