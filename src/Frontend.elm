module Frontend exposing (..)

import Authentication
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Data.Data as Data
import Frontend.Cmd
import Frontend.Update
import Html exposing (Html)
import Lamdera exposing (sendToBackend)
import Task
import Time
import Types exposing (..)
import Url exposing (Url)
import View.Main


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> subscriptions m
        , view = view
        }


subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> GotNewWindowDimensions w h)
        , Time.every 1000 Tick
        ]


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , url = url
      , message = "Welcome!"
      , time = Time.millisToPosix 0
      , zone = Time.utc

      -- ADMIN
      , users = []

      -- LOG
      , inputStartTime = ""
      , inputEndTime = ""
      , startTime = Nothing
      , endTime = Nothing
      , description = ""
      , dataFile = Nothing
      , job = ""
      , jobFilter = ""
      , taskFilter = ""

      -- UI
      , windowWidth = 600
      , windowHeight = 900
      , popupStatus = PopupClosed

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      }
    , Cmd.batch
        [ Frontend.Cmd.setupWindow
        , Task.perform AdjustTimeZone Time.here
        ]
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        -- SYSTEM
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Cmd.none )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        -- UI
        GotNewWindowDimensions w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        ChangePopupStatus status ->
            ( { model | popupStatus = status }, Cmd.none )

        GotViewport vp ->
            Frontend.Update.updateWithViewport vp model

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        -- LOG
        InputStartTime str ->
            ( { model | inputStartTime = str }, Cmd.none )

        InputEndTime str ->
            ( { model | inputEndTime = str }, Cmd.none )

        InputDescription str ->
            ( { model | description = str }, Cmd.none )

        InputJob str ->
            ( { model | job = str }, Cmd.none )

        InputJobFilter str ->
            ( { model | jobFilter = str }, Cmd.none )

        InputTaskFilter str ->
            ( { model | taskFilter = str }, Cmd.none )

        SetStartTime ->
            ( { model | startTime = Just model.time }, Cmd.none )

        SetEndTime ->
            ( { model | endTime = Just model.time }, Cmd.none )

        SaveItem ->
            case ( ( model.dataFile, model.startTime, model.endTime ), model.currentUser ) of
                ( ( Just dataFile, Just startTime, Just endTime ), Just user ) ->
                    let
                        datum =
                            Data.Task { start = startTime, end = endTime, desc = model.description, job = model.job }

                        newDataFile =
                            Data.insertDatum_ dataFile.owner dataFile.name datum dataFile
                    in
                    ( { model | dataFile = Just newDataFile, startTime = Nothing, endTime = Nothing, description = "" }
                    , sendToBackend (SaveDatum ( user, dataFile.name ) datum)
                    )

                ( ( Nothing, _, _ ), _ ) ->
                    ( { model | message = "Sorry, no log file" }, Cmd.none )

                ( ( _, Nothing, _ ), _ ) ->
                    ( { model | message = "Sorry, start time not set" }, Cmd.none )

                ( ( _, _, Nothing ), _ ) ->
                    ( { model | message = "Sorry, end time not set" }, Cmd.none )

                ( _, _ ) ->
                    ( { model | message = "Sorry, no user signed in!" }, Cmd.none )

        -- USER
        SignIn ->
            if String.length model.inputPassword >= 8 then
                ( model
                , sendToBackend (SignInOrSignUp model.inputUsername (Authentication.encrypt model.inputPassword))
                )

            else
                ( { model | message = "Password must be at least 8 letters long." }, Cmd.none )

        InputUsername str ->
            ( { model | inputUsername = str }, Cmd.none )

        InputPassword str ->
            ( { model | inputPassword = str }, Cmd.none )

        SignOut ->
            ( { model
                | currentUser = Nothing
                , message = "Signed out"
                , inputUsername = ""
                , inputPassword = ""
                , job = ""
                , description = ""
              }
            , Cmd.none
            )

        -- ADMIN
        AdminRunTask ->
            ( model, sendToBackend RunTask )

        GetUsers ->
            ( model, sendToBackend SendUsers )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        -- ADMIN
        GotUsers users ->
            ( { model | users = users }, Cmd.none )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )

        GotDataFile dataFile ->
            ( { model | dataFile = Just dataFile }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = ""
    , body =
        [ View.Main.view model ]
    }
