module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V1.Authentication
import Evergreen.V1.User
import Http
import Random
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
    , users : List Evergreen.V1.User.User
    , currentUser : Maybe Evergreen.V1.User.User
    , inputUsername : String
    , inputPassword : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V1.Authentication.AuthenticationDict
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotViewport Browser.Dom.Viewport
    | NoOpFrontendMsg
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | AdminRunTask
    | GetUsers


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V1.User.User)
    | SendUser Evergreen.V1.User.User
