module Backend.Update exposing
    ( gotAtomsphericRandomNumber
    , setupUser
    )

import Authentication
import Lamdera exposing (ClientId, broadcast, sendToFrontend)
import Random
import Token
import Types exposing (..)
import User exposing (User)


type alias Model =
    BackendModel



-- SYSTEM


gotAtomsphericRandomNumber : Model -> Result error String -> ( Model, Cmd msg )
gotAtomsphericRandomNumber model result =
    case result of
        Ok str ->
            case String.toInt (String.trim str) of
                Nothing ->
                    ( model, Cmd.none )

                Just rn ->
                    let
                        newRandomSeed =
                            Random.initialSeed rn
                    in
                    ( { model
                        | randomAtmosphericInt = Just rn
                        , randomSeed = newRandomSeed
                      }
                    , Cmd.none
                    )

        Err _ ->
            ( model, Cmd.none )



-- USER


setupUser : Model -> ClientId -> String -> String -> ( BackendModel, Cmd BackendMsg )
setupUser model clientId username encryptedPassword =
    let
        { token, seed } =
            Token.get model.randomSeed

        tokenData =
            Token.get seed

        user =
            { username = username, id = tokenData.token, realname = "Undefined", email = "Undefined" }

        newAuthDict =
            Authentication.insert user encryptedPassword model.authenticationDict
    in
    ( { model | randomSeed = tokenData.seed, authenticationDict = newAuthDict }
    , Cmd.batch
        [ sendToFrontend clientId (SendMessage "Success! You have set up your account")
        , sendToFrontend clientId (SendUser user)
        ]
    )
