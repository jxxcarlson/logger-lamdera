module Evergreen.V27.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V27.Authentication
import Evergreen.V27.Data.Data
import Evergreen.V27.User
import File exposing (File)
import Http
import Random
import Time
import Url


type DataEntryMode
    = StandardDataEntry
    | EditItemEntry


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type UIMode
    = DefaultMode
    | EditMode


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , time : Time.Posix
    , zone : Time.Zone
    , randomSeed : Random.Seed
    , dataEntryMode : DataEntryMode
    , users : List Evergreen.V27.User.User
    , inputStartTime : String
    , inputEndTime : String
    , startTime : Maybe Time.Posix
    , endTime : Maybe Time.Posix
    , description : String
    , job : String
    , totalValue : Float
    , count : Int
    , hourlyRate : String
    , jobFilter : String
    , taskFilter : String
    , sinceDayFilter : String
    , dataFile : Maybe Evergreen.V27.Data.Data.DataFile
    , filteredData : List Evergreen.V27.Data.Data.Data
    , currentDatum : Maybe Evergreen.V27.Data.Data.Data
    , csv : Maybe String
    , currentUser : Maybe Evergreen.V27.User.User
    , inputUsername : String
    , inputPassword : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , mode : UIMode
    }


type alias BackendModel =
    { message : String
    , time : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V27.Authentication.AuthenticationDict
    , dataDict : Evergreen.V27.Data.Data.DataDict
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotViewport Browser.Dom.Viewport
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
    | NoOpFrontendMsg
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | ToggleMode
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
    | EditItem Evergreen.V27.Data.Data.Data
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | AdminRunTask
    | GetUsers
    | Test


type alias DataFileName =
    String


type ToBackend
    = NoOpToBackend
    | GetAtmosphericInteger
    | RunTask
    | SendUsers
    | SignInOrSignUp String String
    | GetDatafile ( Evergreen.V27.User.User, DataFileName )
    | SaveDatum ( Evergreen.V27.User.User, DataFileName ) Evergreen.V27.Data.Data.Data
    | ReplaceDatum ( Evergreen.V27.User.User, DataFileName ) Evergreen.V27.Data.Data.Data
    | ReplaceDataFile Evergreen.V27.Data.Data.DataFile


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumberBE (Result Http.Error String)
    | BTick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | GotRandomSeed Random.Seed
    | GotAtmosphericInteger (Maybe Int)
    | SendMessage String
    | GotUsers (List Evergreen.V27.User.User)
    | SendUser Evergreen.V27.User.User
    | GotDataFile Evergreen.V27.Data.Data.DataFile
