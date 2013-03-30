{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}

module SMACCMPilot.Flight.Control.Task where

import Ivory.Language
import Ivory.Tower
import qualified Ivory.OS.FreeRTOS as OS

import qualified SMACCMPilot.Flight.Types.FlightMode as FM
import qualified SMACCMPilot.Flight.Types.UserInput as UI
import qualified SMACCMPilot.Flight.Types.Sensors as SENS
import qualified SMACCMPilot.Flight.Types.ControlOutput as CO

import SMACCMPilot.Flight.Control.Stabilize

import SMACCMPilot.Util.Periodic

controlTask :: Sink (Struct "flightmode")
            -> Sink (Struct "userinput_result")
            -> Sink (Struct "sensors_result")
            -> Source (Struct "controloutput")
            -> String -> Task
controlTask s_fm s_inpt s_sensors s_ctl uniquename =
  withSink   "flightmode" s_fm      $ \flightmodeSink->
  withSink   "userinput"  s_inpt    $ \userinputSink ->
  withSink   "sensors"    s_sensors $ \sensorsSink ->
  withSource "control"    s_ctl     $ \controlSource ->
  let tDef = proc ("stabilizeTaskDef" ++ uniquename) $ body $ do
        fm   <- local (istruct [])
        inpt <- local (istruct [])
        sens <- local (istruct [])
        ctl  <- local (istruct [])
        periodic 50 $ do
          sink flightmodeSink fm
          sink userinputSink  inpt
          sink sensorsSink    sens
          call (direct_ stabilize_run fm inpt sens ctl)
          source controlSource (constRef ctl)

      mDefs = do
        depend OS.taskModule
        depend FM.flightModeTypeModule
        depend UI.userInputTypeModule
        depend SENS.sensorsTypeModule
        depend CO.controlOutputTypeModule
        depend stabilizeControlLoopsModule
        incl tDef
  in task tDef mDefs
