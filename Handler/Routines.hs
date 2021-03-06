{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
module Handler.Routines where

import Import

-- This is a handler function for the GET request method on the HomeR
-- resource pattern. All of your resource patterns are defined in
-- config/routes
--
-- The majority of the code you will write in Yesod lives in these handler
-- functions. You can spread them across multiple files if you are so
-- inclined, or create a single monolithic file.
getRoutinesR :: Handler Value
getRoutinesR = do
    allRoutines <- runDB (selectList [] [])
    returnJson . map removeEntityRoutineData . asRoutineEntities $ allRoutines
  where
    removeEntityRoutineData :: Entity Routine -> Entity Routine
    removeEntityRoutineData (Entity key routine) =
        let removeRoutineData = routine { routineData = "" }
        in Entity key $ removeRoutineData
    asRoutineEntities :: [Entity Routine] -> [Entity Routine]
    asRoutineEntities = id

postRoutinesR :: Handler Value
postRoutinesR = do
    routine <- requireJsonBody :: Handler Routine
    rid <- runDB . insert $ routine
    sendResponseCreated $ RoutineR rid

getRoutineR :: RoutineId -> Handler Value
getRoutineR rid = do
    routine <- runDB (get404 rid)
    returnJson routine

putRoutineR :: RoutineId -> Handler Value
putRoutineR = getRoutineR