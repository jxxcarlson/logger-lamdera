module Backend exposing (..)

import Authentication
import Backend.Cmd
import Backend.Update
import Data.Data exposing (DataType(..))
import Data.Manager
import Dict
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import Random
import Time
import Token
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Time.every 86400000 BTick
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"
      , time = Time.millisToPosix 0

      -- RANDOM
      , randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , randomAtmosphericInt = Nothing

      -- USER
      , authenticationDict = Dict.empty
      , dataDict = Dict.empty
      }
    , Backend.Cmd.getRandomNumberBE
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        BTick newTime ->
            ( { model | time = newTime }
            , Backend.Cmd.getRandomNumberBE
            )

        GotAtomsphericRandomNumberBE result ->
            Backend.Update.gotAtomsphericRandomNumber model result


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        -- SYSTEM
        NoOpToBackend ->
            ( model, Cmd.none )

        GetAtmosphericInteger ->
            ( model, sendToFrontend clientId (GotAtmosphericInteger model.randomAtmosphericInt) )

        -- ADMIN
        RunTask ->
            --case Data.Manager.setupLog_ model.time "jxxcarlson" "Work Log" TTask model.authenticationDict model.dataDict of
            --    Err errs ->
            --        ( model, sendToFrontend clientId (SendMessage errs) )
            --
            --    Ok dataDict ->
            --        ( { model | dataDict = dataDict }, sendToFrontend clientId (SendMessage ("New log set up: " ++ "Work Log")) )
            ( model, sendToFrontend clientId (SendMessage "No task to run") )

        SendUsers ->
            ( model, sendToFrontend clientId (GotUsers (Authentication.users model.authenticationDict)) )

        -- USER
        SignInOrSignUp username encryptedPassword ->
            case Dict.get username model.authenticationDict of
                Just userData ->
                    if Authentication.verify username encryptedPassword model.authenticationDict then
                        case Dict.get ( username, "Work Log" ) model.dataDict of
                            Nothing ->
                                ( model
                                , Cmd.batch
                                    [ sendToFrontend clientId (SendUser userData.user)
                                    , sendToFrontend clientId
                                        (SendMessage <| "Success! You are signed in, but there is no data file ")
                                    , Backend.Cmd.verifyRandomAtmosphericInteger model
                                    ]
                                )

                            Just dataFile ->
                                ( model
                                , Cmd.batch
                                    [ sendToFrontend clientId (SendUser userData.user)
                                    , sendToFrontend clientId (GotDataFile dataFile)
                                    , Backend.Cmd.verifyRandomAtmosphericInteger model
                                    , sendToFrontend clientId
                                        (SendMessage <| "Success! You are signed in with random atmospheric integer " ++ String.fromInt (model.randomAtmosphericInt |> Maybe.withDefault 0))
                                    ]
                                )

                    else
                        ( model
                        , Cmd.batch
                            [ Backend.Cmd.verifyRandomAtmosphericInteger model
                            , sendToFrontend clientId (SendMessage "Sorry, password and username don't match")
                            ]
                        )

                Nothing ->
                    Backend.Update.setupUser model clientId username encryptedPassword

        -- LOG
        GetDatafile ( user, dataFileName ) ->
            case Dict.get ( user.username, dataFileName ) model.dataDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "Sorry no access") )

                Just dataFile ->
                    ( model
                    , Cmd.batch
                        [ sendToFrontend clientId (GotDataFile dataFile)
                        , sendToFrontend clientId (SendMessage <| "received log file: " ++ dataFile.name)
                        ]
                    )

        SaveDatum ( user, dataFileName ) datum ->
            ( { model | dataDict = Data.Data.insertDatum user.username dataFileName datum model.dataDict }, Cmd.none )

        ReplaceDatum ( user, dataFileName ) datum ->
            ( { model | dataDict = Data.Data.replaceDatum user.username dataFileName datum model.dataDict }, Cmd.none )

        ReplaceDataFile dataFile ->
            ( { model | dataDict = Data.Data.replace dataFile model.dataDict }, Cmd.none )
