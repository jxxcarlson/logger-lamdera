module Frontend exposing (..)

import Authentication
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Data.Data as Data
import Data.Parse
import DateTimeUtility
import File
import File.Download as Download
import File.Select as Select
import Frontend.Cmd
import Frontend.Update
import Html exposing (Html)
import Lamdera exposing (sendToBackend)
import Random
import Task
import Time
import Token
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
    ( { -- SYSTEM
        key = key
      , url = url
      , message = "Welcome!"
      , time = Time.millisToPosix 0
      , zone = Time.utc
      , randomSeed = Random.initialSeed 1234
      , dataEntryMode = StandardDataEntry

      -- ADMIN
      , users = []

      -- LOG
      , inputStartTime = ""
      , inputEndTime = ""
      , startTime = Nothing
      , endTime = Nothing
      , description = ""
      , dataFile = Nothing
      , filteredData = []
      , currentDatum = Nothing
      , job = ""
      , totalValue = 0
      , count = 0
      , hourlyRate = ""
      , jobFilter = ""
      , taskFilter = ""
      , sinceDayFilter = ""
      , csv = Nothing

      -- UI
      , windowWidth = 600
      , windowHeight = 900
      , popupStatus = PopupClosed
      , mode = DefaultMode

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      }
    , Cmd.batch
        [ Frontend.Cmd.setupWindow
        , Task.perform AdjustTimeZone Time.here
        , sendToBackend GetAtmosphericInteger
        , Frontend.Cmd.getRandomNumberFE
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

        GotAtomsphericRandomNumberFE result ->
            case result of
                Ok str ->
                    case String.toInt (String.trim str) of
                        Nothing ->
                            ( { model | message = "Failed to get atmospheric random number" }, Cmd.none )

                        Just rn ->
                            let
                                newRandomSeed =
                                    Random.initialSeed rn
                            in
                            ( { model
                                | randomSeed = newRandomSeed
                              }
                            , Cmd.none
                            )

                Err _ ->
                    ( model, Cmd.none )

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
            let
                filteredData =
                    filterData2 model str model.taskFilter model.sinceDayFilter
            in
            ( { model
                | jobFilter = str
                , filteredData = filteredData
                , totalValue = Data.totalValue filteredData
                , count = List.length filteredData
              }
            , Cmd.none
            )

        InputTaskFilter str ->
            let
                filteredData =
                    filterData2 model model.jobFilter str model.sinceDayFilter
            in
            ( { model
                | taskFilter = str
                , totalValue = Data.totalValue filteredData
                , filteredData = filteredData
                , count = List.length filteredData
              }
            , Cmd.none
            )

        InputSinceDayFilter str ->
            let
                filteredData =
                    filterData2 model model.jobFilter model.taskFilter str
            in
            ( { model
                | sinceDayFilter = str
                , filteredData = filteredData
                , totalValue = Data.totalValue filteredData
                , count = List.length filteredData
              }
            , Cmd.none
            )

        InputHourlyRate str ->
            ( { model | hourlyRate = str }, Cmd.none )

        SetStartTime ->
            ( { model | startTime = Just model.time }, Cmd.none )

        SetEndTime ->
            ( { model | endTime = Just model.time }, Cmd.none )

        EditItem datum ->
            ( { model
                | message = "Editing " ++ Data.getId datum
                , currentDatum = Just datum
                , dataEntryMode = EditItemEntry
                , job = Data.getJob datum
                , description = Data.getDescription datum
                , inputStartTime = DateTimeUtility.zonedTimeString model.zone (Data.getStartTimeAsPosix datum)
                , inputEndTime = DateTimeUtility.zonedTimeString model.zone (Data.getEndTimeAsPosix datum)
              }
            , Cmd.none
            )

        SaveItem ->
            case model.dataEntryMode of
                StandardDataEntry ->
                    Frontend.Update.saveItem model

                EditItemEntry ->
                    Frontend.Update.saveEditedItem model.currentDatum model

        ExportTimeSheet ->
            ( { model | message = "Exporting timesheet ..." }, Data.saveTimeSheet model.zone model.filteredData )

        ExportData ->
            ( { model | message = "Exporting data ..." }, Data.saveData model.zone model.filteredData )

        CsvRequested ->
            ( model
            , Select.file [ "text/csv" ] CsvSelected
            )

        CsvSelected file ->
            ( model
            , Task.perform CsvLoaded (File.toString file)
            )

        CsvLoaded content ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    let
                        dataList =
                            Data.Parse.parseTasks content

                        dataFile =
                            Data.Parse.createDataFileFromTasks model.time user.username dataList
                    in
                    ( { model | csv = Just content, dataFile = Just dataFile, message = "CSV loaded: " ++ String.fromInt (String.length content) ++ " chars" }
                    , sendToBackend (ReplaceDataFile dataFile)
                    )

        -- USER
        SignIn ->
            if String.length model.inputPassword >= 8 then
                ( model
                , sendToBackend (SignInOrSignUp model.inputUsername (Authentication.encryptForTransit model.inputPassword))
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
                , jobFilter = ""
                , sinceDayFilter = ""
                , taskFilter = ""
              }
            , Cmd.none
            )

        -- ADMIN
        AdminRunTask ->
            ( model, sendToBackend RunTask )

        Test ->
            ( model, sendToBackend GetAtmosphericInteger )

        GetUsers ->
            ( model, sendToBackend SendUsers )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        -- SYSTEM
        NoOpToFrontend ->
            ( model, Cmd.none )

        GotRandomSeed seed ->
            ( { model
                | randomSeed = seed
                , message = "Got random seed"
              }
            , Cmd.none
            )

        GotAtmosphericInteger mn ->
            case mn of
                Nothing ->
                    ( { model | message = "Atmospheric random int: UNDEFINED" }, Cmd.none )

                Just n ->
                    ( { model | message = "Atmospheric random number = " ++ String.fromInt n }, Cmd.none )

        -- ADMIN
        GotUsers users ->
            ( { model | users = users }, Cmd.none )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )

        GotDataFile dataFile ->
            ( { model
                | dataFile = Just dataFile
                , filteredData = dataFile.data
                , totalValue = Data.totalValue dataFile.data
                , count = List.length dataFile.data
              }
            , Cmd.none
            )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = ""
    , body =
        [ View.Main.view model ]
    }



-- HELPERS


filterData2 : Model -> String -> String -> String -> List Data.Data
filterData2 model jobFilter taskFilter sinceDayFilter =
    Data.filterData model.time jobFilter taskFilter sinceDayFilter (Maybe.map .data model.dataFile |> Maybe.withDefault [])


filterData : Model -> List Data.Data
filterData model =
    case model.dataFile of
        Nothing ->
            []

        Just theData ->
            Data.filterData model.time model.jobFilter model.taskFilter model.sinceDayFilter theData.data
