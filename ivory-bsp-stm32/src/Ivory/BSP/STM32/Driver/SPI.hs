{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Ivory.BSP.STM32.Driver.SPI
  ( spiTower
  , module Ivory.BSP.STM32.Driver.SPI.Types
  , module Ivory.BSP.STM32.Driver.SPI.SPIDeviceHandle
  ) where

import Ivory.Language
import Ivory.Stdlib
import Ivory.Tower
import Ivory.HW

import Ivory.BSP.STM32.Interrupt
import Ivory.BSP.STM32.ClockConfig

import Ivory.BSP.STM32.Peripheral.GPIOF4
import Ivory.BSP.STM32.Peripheral.SPI.Regs
import Ivory.BSP.STM32.Peripheral.SPI.Peripheral

import Ivory.BSP.STM32.Driver.SPI.Types
import Ivory.BSP.STM32.Driver.SPI.SPIDeviceHandle


spiTower :: forall s e
          . (HasClockConfig e, Signalable s, STM32Interrupt s)
         => [SPIDevice s]
         -> Tower e ( ChanInput (Struct "spi_transaction_request")
                    , ChanOutput   (Struct "spi_transaction_result"))
spiTower devices = do
  towerDepends spiDriverTypes
  towerModule  spiDriverTypes
  reqchan <- channel
  reschan <- channel
  irq <- signalUnsafe interrupt (Microseconds 20)
                (do debugToggle debugPin1
                    interrupt_disable interrupt)
  monitor (periphname ++ "PeripheralDriver") $
    spiPeripheralDriver periph devices (snd reqchan) (fst reschan) irq
  return (fst reqchan, snd reschan)
  where
  interrupt = spiInterrupt periph
  periphname = spiName periph
  periph = case devices of
    [] -> err "for an empty device set"
    d:ds ->
      let canonicalp = spiDevPeripheral d
      in case and (map (\d' -> canonicalp `eqname` spiDevPeripheral d') ds) of
        True -> canonicalp
        False -> err "with devices on different peripherals"
  eqname a b = spiName a == spiName b
  err m = error ("spiTower cannot be created " ++ m)


spiPeripheralDriver :: forall s e
                     . (Signalable s, STM32Interrupt s, HasClockConfig e)
                    => SPIPeriph s
                    -> [SPIDevice s]
                    -> ChanOutput   (Struct "spi_transaction_request")
                    -> ChanInput    (Struct "spi_transaction_result")
                    -> ChanOutput (Stored ITime)
                    -> Monitor e ()
spiPeripheralDriver periph devices req_out res_in irq = do
  clockconfig <- getClockConfig
  monitorModuleDef $ hw_moduledef
  done <- state "done"
  handler systemInit "initialize_hardware"$ callback $ \_ -> do
    debugSetup     debugPin1
    debugSetup     debugPin2
    debugSetup     debugPin3
    spiInit        periph
    interrupt_set_to_syscall_priority interrupt
    mapM_ spiDeviceInit devices
    store done true

  reqbuffer    <- state "reqbuffer"
  reqbufferpos <- state "reqbufferpos"

  resbuffer    <- state "resbuffer"
  resbufferpos <- state "resbufferpos"


  handler irq "irq" $ do
    e <- emitter res_in 1
    callback $ \_ -> do
      tx_pos <- deref reqbufferpos
      tx_sz  <- deref (reqbuffer ~> tx_len)
      rx_pos <- deref resbufferpos
      rx_sz  <- deref (resbuffer ~> rx_idx)

      sr <- getReg (spiRegSR periph)
      cond_
        [ bitToBool (sr #. spi_sr_rxne) ==> do
            debugOn debugPin2
            when (rx_pos <? rx_sz) $ do
              r <- spiGetDR periph
              store ((resbuffer ~> rx_buf) ! rx_pos) r
              store resbufferpos (rx_pos + 1)
            when (rx_pos ==? (rx_sz - 1)) $ do
              modifyReg (spiRegCR2 periph) (clearBit spi_cr2_txeie)
              spiBusEnd       periph
              chooseDevice spiDeviceDeselect (reqbuffer ~> tx_device)
              emit e (constRef resbuffer)
              store done true
            debugOff debugPin2

        , bitToBool (sr #. spi_sr_txe) ==> do
            debugOn debugPin3
            when (tx_pos <? tx_sz) $ do
              w <- deref ((reqbuffer ~> tx_buf) ! tx_pos)
              spiSetDR periph w
            ifte_ (tx_pos <=? tx_sz)
              (do store reqbufferpos (tx_pos + 1)
                  modifyReg (spiRegCR2 periph) (setBit spi_cr2_rxneie))
              (modifyReg (spiRegCR2 periph) (clearBit spi_cr2_rxneie))
            debugOff debugPin3
        ]
      interrupt_enable interrupt

  let deviceBeginProc :: SPIDevice i -> Def('[]:->())
      deviceBeginProc dev = proc ((spiDevName dev) ++ "_devicebegin") $
        body $ do
          spiBusBegin clockconfig dev
          spiDeviceSelect dev

  monitorModuleDef $ do
    mapM_ (incl . deviceBeginProc) devices

  handler req_out  "request" $ do
    callback $ \req -> do
      ready <- deref done
      when ready $ do
        store done false
        -- Initialize request and result state
        refCopy reqbuffer req
        reqlen <- deref (reqbuffer ~> tx_len)
        store reqbufferpos 0
        store resbufferpos 0
        store (resbuffer ~> rx_idx) reqlen
        -- Get the first byte to transmit
        tx0 <- deref ((reqbuffer ~> tx_buf) ! 0)
        store reqbufferpos 1
        -- select the device and setup the spi peripheral
        chooseDevice (call_ . deviceBeginProc) (reqbuffer ~> tx_device)
        -- Send the first byte, enable tx empty interrupt
        spiSetDR  periph tx0
        modifyReg (spiRegCR2 periph) (setBit spi_cr2_txeie)
        interrupt_enable interrupt

      unless ready $ do
        return () -- XXX how do we want to handle this error?

  where
  interrupt = spiInterrupt periph

  chooseDevice :: (SPIDevice s -> Ivory eff ())
               -> Ref Global (Stored SPIDeviceHandle) -> Ivory eff ()
  chooseDevice cb devref = do
    comment "selecting device:"
    currdev <- deref devref
    assert (currdev <? invalidhandle)
    cond_ (zipWith (aux currdev) devices [(0::Integer)..])
    comment "end selecting configured device"
    where
    invalidhandle = SPIDeviceHandle (fromIntegral (length devices))
    aux cd device idx =
      cd ==? SPIDeviceHandle (fromIntegral idx) ==> cb device


-- Debugging Helpers: useful for development, disabled for production.
debugPin1, debugPin2, debugPin3 :: Maybe GPIOPin
debugPin1 = Nothing
debugPin2 = Nothing
debugPin3 = Nothing
--debugPin1 = Just pinE2
--debugPin2 = Just pinE4
--debugPin3 = Just pinE5

debugSetup :: Maybe GPIOPin -> Ivory eff ()
debugSetup (Just p) = do
  pinEnable        p
  pinSetOutputType p gpio_outputtype_pushpull
  pinSetSpeed      p gpio_speed_50mhz
  pinSetPUPD       p gpio_pupd_none
  pinClear         p
  pinSetMode       p gpio_mode_output
debugSetup Nothing = return ()

debugOff :: Maybe GPIOPin -> Ivory eff ()
debugOff (Just p) = pinClear p
debugOff Nothing  = return ()

debugOn :: Maybe GPIOPin -> Ivory eff ()
debugOn (Just p) = pinSet p
debugOn Nothing  = return ()

debugToggle :: Maybe GPIOPin -> Ivory eff ()
debugToggle p = debugOn p >> debugOff p

