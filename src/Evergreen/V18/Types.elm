module Evergreen.V18.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V18.Authentication
import Evergreen.V18.Data.Data
import Evergreen.V18.User
import File exposing (File)
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
    , users : List Evergreen.V18.User.User
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
    , dataFile : Maybe Evergreen.V18.Data.Data.DataFile
    , filteredData : List Evergreen.V18.Data.Data.Data
    , csv : Maybe String
    , currentUser : Maybe Evergreen.V18.User.User
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
    , authenticationDict : Evergreen.V18.Authentication.AuthenticationDict
    , dataDict : Evergreen.V18.Data.Data.DataDict
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
    | ExportTimeSheet
    | ExportData
    | CsvRequested
    | CsvSelected File
    | CsvLoaded String
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
    | GetDatafile ( Evergreen.V18.User.User, DataFileName )
    | SaveDatum ( Evergreen.V18.User.User, DataFileName ) Evergreen.V18.Data.Data.Data
    | ReplaceDataFile Evergreen.V18.Data.Data.DataFile


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | BTick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V18.User.User)
    | SendUser Evergreen.V18.User.User
    | GotDataFile Evergreen.V18.Data.Data.DataFile
