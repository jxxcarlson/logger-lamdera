module Authentication exposing (AuthenticationDict, encrypt, insert, users, verify)

import Crypto.HMAC exposing (sha256)
import Dict exposing (Dict)
import Env
import User exposing (User)


type alias Username =
    String


type alias UserData =
    { user : User, token : String }


type alias AuthenticationDict =
    Dict Username UserData


users : AuthenticationDict -> List User
users authDict =
    authDict |> Dict.values |> List.map .user


insert : User -> String -> AuthenticationDict -> AuthenticationDict
insert user encryptedPassword authDict =
    Dict.insert user.username { user = user, token = encryptedPassword } authDict


encrypt : String -> String
encrypt str =
    Crypto.HMAC.digest sha256 Env.authKey str


verify : String -> String -> AuthenticationDict -> Bool
verify username encryptedPassword authDict =
    case Dict.get username authDict of
        Nothing ->
            False

        Just data ->
            encryptedPassword == data.token
