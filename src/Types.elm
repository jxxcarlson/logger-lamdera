module Types exposing (..)

import Authentication exposing (AuthenticationDict)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation exposing (Key)
import Data.Data exposing (Data, DataFile)
import File exposing (File)
import Http
import Random
import Task
import Time
import Url exposing (Url)
import User exposing (User)


type alias FrontendModel =
    { -- SYSTEM
      key : Key
    , url : Url
    , message : String
    , time : Time.Posix
    , zone : Time.Zone
    , randomSeed : Random.Seed

    -- ADMIN
    , users : List User

    -- LOG
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
    , dataFile : Maybe DataFile
    , filteredData : List Data
    , csv : Maybe String

    -- USER
    , currentUser : Maybe User
    , inputUsername : String
    , inputPassword : String

    -- UI
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , mode : UIMode
    }


type UIMode
    = DefaultMode
    | EditMode


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias BackendModel =
    { message : String
    , time : Time.Posix

    -- RANDOM
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int

    -- USER
    , authenticationDict : AuthenticationDict
    , dataDict : Data.Data.DataDict
    }


type FrontendMsg
    = -- SYSTEM
      UrlClicked UrlRequest
    | UrlChanged Url
    | GotViewport Dom.Viewport
    | Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
    | NoOpFrontendMsg
      -- UI
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | ToggleMode
      -- LOG
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
    | CsvSelected File.File
    | CsvLoaded String
      -- USER
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
      -- ADMIN
    | AdminRunTask
    | GetUsers
    | Test


type ToBackend
    = -- SYSTEM
      NoOpToBackend
    | GetAtmosphericInteger
      -- ADMIN
    | RunTask
    | SendUsers
      -- USER
    | SignInOrSignUp String String
      -- LOG
    | GetDatafile ( User, DataFileName )
    | SaveDatum ( User, DataFileName ) Data
    | ReplaceDataFile DataFile


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumberBE (Result Http.Error String)
    | BTick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | GotRandomSeed Random.Seed
    | GotAtmosphericInteger (Maybe Int)
    | SendMessage String
      -- ADMIN
    | GotUsers (List User)
      -- USER
    | SendUser User
    | GotDataFile DataFile


type alias UserName =
    String


type alias DataFileName =
    String
