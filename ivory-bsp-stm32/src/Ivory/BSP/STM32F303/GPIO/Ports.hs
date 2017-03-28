{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}

module Ivory.BSP.STM32F303.GPIO.Ports
  ( gpioA
  , gpioB
  , gpioC
  , gpioD
  , gpioE
  , gpioF
  ) where

import Ivory.Language
import Ivory.HW

import Ivory.BSP.STM32.Peripheral.GPIOF4.Peripheral

import Ivory.BSP.STM32F303.MemoryMap
import Ivory.BSP.STM32F303.RCC

gpioA :: GPIOPort
gpioA = mkGPIOPort gpioa_periph_base
          (rccEnable rcc_ahb1en_gpioa)
          (rccDisable rcc_ahb1en_gpioa)
          0

gpioB :: GPIOPort
gpioB = mkGPIOPort gpiob_periph_base
          (rccEnable rcc_ahb1en_gpiob)
          (rccDisable rcc_ahb1en_gpiob)
          1

gpioC :: GPIOPort
gpioC = mkGPIOPort gpioc_periph_base
          (rccEnable rcc_ahb1en_gpioc)
          (rccDisable rcc_ahb1en_gpioc)
          2

gpioD :: GPIOPort
gpioD = mkGPIOPort gpiod_periph_base
          (rccEnable rcc_ahb1en_gpiod)
          (rccDisable rcc_ahb1en_gpiod)
          3

gpioE :: GPIOPort
gpioE = mkGPIOPort gpioe_periph_base
          (rccEnable rcc_ahb1en_gpioe)
          (rccDisable rcc_ahb1en_gpioe)
          4

gpioF :: GPIOPort
gpioF = mkGPIOPort gpiof_periph_base
          (rccEnable rcc_ahb1en_gpiof)
          (rccDisable rcc_ahb1en_gpiof)
          5

rccEnable :: BitDataField RCC_AHB1ENR Bit -> Ivory eff ()
rccEnable f = modifyReg regRCC_AHB1ENR $ setBit f
rccDisable :: BitDataField RCC_AHB1ENR Bit -> Ivory eff ()
rccDisable f = modifyReg regRCC_AHB1ENR $ clearBit f

