module Evergreen.V15.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V15.Authentication
import Evergreen.V15.Data.Data
import Evergreen.V15.User
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
    , users : List Evergreen.V15.User.User
    , inputStartTime : String
    , inputEndTime : String
    , startTime : Maybe Time.Posix
    , endTime : Maybe Time.Posix
    , description : String
    , job : String
    , totalValue : Float
    , hourlyRate : String
    , jobFilter : String
    , taskFilter : String
    , sinceDayFilter : String
    , dataFile : Maybe Evergreen.V15.Data.Data.DataFile
    , filteredData : List Evergreen.V15.Data.Data.Data
    , currentUser : Maybe Evergreen.V15.User.User
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
    , authenticationDict : Evergreen.V15.Authentication.AuthenticationDict
    , dataDict : Evergreen.V15.Data.Data.DataDict
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
    | InputJob String
    | InputJobFilter String
    | InputTaskFilter String
    | InputSinceDayFilter String
    | InputHourlyRate String
    | SetStartTime
    | SetEndTime
    | SaveItem
    | ExportCSV
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
    | GetDatafile ( Evergreen.V15.User.User, DataFileName )
    | SaveDatum ( Evergreen.V15.User.User, DataFileName ) Evergreen.V15.Data.Data.Data


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | BTick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V15.User.User)
    | SendUser Evergreen.V15.User.User
    | GotDataFile Evergreen.V15.Data.Data.DataFile
