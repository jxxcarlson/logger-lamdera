module Backend.Update exposing
    ( gotAtomsphericRandomNumber
    , setupUser
    )

import Authentication
import Data.Data exposing (DataType(..))
import Data.Manager
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
                        | randomAtmosphericInt = Debug.log "ATMOS (2)" (Just rn)
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

        newDataFile =
            Data.Data.newDataFile model.time username "Work Log" TTask

        newDataDict =
            Data.Manager.setupLog model.time username "Work Log" TTask newAuthDict model.dataDict
    in
    ( { model | randomSeed = tokenData.seed, authenticationDict = newAuthDict, dataDict = newDataDict }
    , Cmd.batch
        [ sendToFrontend clientId (SendUser user)
        , sendToFrontend clientId (SendMessage "We have set up your new account and Work Log")
        , sendToFrontend clientId (GotDataFile newDataFile)
        ]
    )
