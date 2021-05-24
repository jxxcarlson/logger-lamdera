module Evergreen.V21.Authentication exposing (..)

import Dict
import Evergreen.V21.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V21.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
