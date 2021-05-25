module Frontend.Update exposing
    ( saveEditedItem
    , saveItem
    , updateWithViewport
    )

import Data.Data as Data
import DateTimeUtility
import Lamdera exposing (sendToBackend)
import List.Extra
import Token
import Types exposing (..)


updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
      }
    , Cmd.none
    )


saveEditedItem currentDatum model =
    case currentDatum of
        Nothing ->
            ( { model | dataEntryMode = StandardDataEntry, message = "No edit item to save." }, Cmd.none )

        Just datum ->
            case ( model.dataFile, model.currentUser ) of
                ( Nothing, _ ) ->
                    ( { model | dataEntryMode = StandardDataEntry, message = "No data file  to save in" }, Cmd.none )

                ( _, Nothing ) ->
                    ( { model | dataEntryMode = StandardDataEntry, message = "No user for whom to save" }, Cmd.none )

                ( Just dataFile, Just user ) ->
                    let
                        startTime =
                            DateTimeUtility.zonedTimeString model.zone (Data.getStartTimeAsPosix datum)

                        newStartTime =
                            DateTimeUtility.changeTime startTime model.inputStartTime (Data.getStartTimeAsPosix datum)

                        endTime =
                            DateTimeUtility.zonedTimeString model.zone (Data.getEndTimeAsPosix datum)

                        newEndTime =
                            DateTimeUtility.changeTime endTime model.inputEndTime (Data.getEndTimeAsPosix datum)

                        newDatum =
                            datum
                                |> Data.updateJob model.job
                                |> Data.updateDescription model.description
                                |> Data.updateStartTime newStartTime
                                |> Data.updateEndTime newEndTime

                        newFilteredData =
                            List.Extra.setIf (\datum_ -> Data.getId datum_ == Data.getId newDatum) newDatum model.filteredData

                        newDataFile =
                            Data.replaceDatumInDataFile newDatum dataFile
                    in
                    ( { model
                        | dataEntryMode = StandardDataEntry
                        , filteredData = newFilteredData
                        , dataFile = Just newDataFile
                        , totalValue = Data.totalValue newFilteredData
                        , count = List.length newFilteredData
                        , currentDatum = Nothing
                        , message = "Edited item saved."
                      }
                    , sendToBackend (ReplaceDatum ( user, dataFile.name ) newDatum)
                    )


saveItem model =
    case ( ( model.dataFile, model.startTime, model.endTime ), model.currentUser ) of
        ( ( Just dataFile, Just startTime, Just endTime ), Just user ) ->
            let
                { token, seed } =
                    Token.get model.randomSeed

                datum =
                    Data.Task
                        { id = dataFile.owner ++ "-" ++ model.job ++ "-" ++ token
                        , start = startTime
                        , end = endTime
                        , desc = model.description
                        , job = model.job
                        }

                filteredData =
                    Data.filterData model.time model.jobFilter model.taskFilter model.sinceDayFilter newDataFile.data

                newDataFile =
                    Data.insertDatum_ dataFile.owner dataFile.name datum dataFile
            in
            ( { model
                | randomSeed = seed
                , dataFile = Just newDataFile
                , filteredData = filteredData
                , totalValue = Data.totalValue filteredData
                , count = List.length filteredData
                , startTime = Nothing
                , endTime = Nothing
                , description = ""
              }
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
