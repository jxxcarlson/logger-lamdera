module Evergreen.V4.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V4.Authentication
import Evergreen.V4.Data.Data
import Evergreen.V4.User
import Http
import Random
import Time
import Url


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , time : Time.Posix
    , zone : Time.Zone
    , users : List Evergreen.V4.User.User
    , inputStartTime : String
    , inputEndTime : String
    , startTime : Maybe Time.Posix
    , endTime : Maybe Time.Posix
    , description : String
    , dataFile : Maybe Evergreen.V4.Data.Data.DataFile
    , currentUser : Maybe Evergreen.V4.User.User
    , inputUsername : String
    , inputPassword : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    }


type alias BackendModel =
    { message : String
    , time : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V4.Authentication.AuthenticationDict
    , dataDict : Evergreen.V4.Data.Data.DataDict
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotViewport Browser.Dom.Viewport
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | NoOpFrontendMsg
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | InputStartTime String
    | InputEndTime String
    | InputDescription String
    | SetStartTime
    | SetEndTime
    | SaveItem
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | AdminRunTask
    | GetUsers


type alias DataFileName =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SignInOrSignUp String String
    | GetDatafile ( Evergreen.V4.User.User, DataFileName )
    | SaveDatum ( Evergreen.V4.User.User, DataFileName ) Evergreen.V4.Data.Data.Data


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | BTick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V4.User.User)
    | SendUser Evergreen.V4.User.User
    | GotDataFile Evergreen.V4.Data.Data.DataFile
