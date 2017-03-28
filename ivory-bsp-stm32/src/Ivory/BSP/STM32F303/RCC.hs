{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- Regs.hs --- RCC (Reset and Clock Control) registers, specific to F303 series
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32F303.RCC where

import Ivory.Language
import Ivory.HW

import Ivory.BSP.STM32F303.MemoryMap (rcc_periph_base)

-- AHB Peripheral Clock Enable Registers ---------------------------------------

-- XXX: technically this is AHBENR
[ivory|
 bitdata RCC_AHB1ENR :: Bits 32 = rcc_ahb1enr
  { _                     :: Bit
  , _                     :: Bit
  , rcc_ahb1en_adc34      :: Bit
  , rcc_ahb1en_adc12      :: Bit
  , _                     :: Bits 3
  , rcc_ahb1en_ts         :: Bit -- touch sensing
  , rcc_ahb1en_gpiog      :: Bit
  , rcc_ahb1en_gpiof      :: Bit
  , rcc_ahb1en_gpioe      :: Bit
  , rcc_ahb1en_gpiod      :: Bit
  , rcc_ahb1en_gpioc      :: Bit
  , rcc_ahb1en_gpiob      :: Bit
  , rcc_ahb1en_gpioa      :: Bit
  , rcc_ahb1en_gpioh      :: Bit
  , _                     :: Bits 9
  , rcc_ahb1en_crc        :: Bit
  , rcc_ahb1en_fmc        :: Bit -- flexible memory controller
  , rcc_ahb1en_flitf      :: Bit
  , _                     :: Bit
  , rcc_ahb1en_sram       :: Bit -- enable SRAM clock during sleep mode
  , rcc_ahb1en_dma2       :: Bit
  , rcc_ahb1en_dma1       :: Bit
  }
|]

regRCC_AHB1ENR :: BitDataReg RCC_AHB1ENR
regRCC_AHB1ENR = mkBitDataRegNamed (rcc_periph_base + 0x14) "rcc_ahb1enr"

[ivory|
 bitdata RCC_AHB2ENR :: Bits 32 = rcc_ahb2enr
  { _                     :: Bits 24
  , rcc_ahb2en_otg_fs     :: Bit
  , rcc_ahb2en_rng        :: Bit
  , rcc_ahb2en_hash       :: Bit
  , rcc_ahb2en_cryp       :: Bit
  , _                     :: Bits 3
  , rcc_ahb2en_dcmi       :: Bit
  }
|]

regRCC_AHB2ENR :: BitDataReg RCC_AHB2ENR
regRCC_AHB2ENR = mkBitDataRegNamed (rcc_periph_base + 0x34) "rcc_ahb2enr"

[ivory|
 bitdata RCC_AHB3ENR :: Bits 32 = rcc_ahb3enr
  { _                     :: Bits 31
  , rcc_ahb3en_fsmc       :: Bit
  }
|]

regRCC_AHB3ENR :: BitDataReg RCC_AHB3ENR
regRCC_AHB3ENR = mkBitDataRegNamed (rcc_periph_base + 0x38) "rcc_ahb3enr"

-- APB Peripheral Clock Enable Registers ---------------------------------------

[ivory|
 bitdata RCC_APB1ENR :: Bits 32 = rcc_apb1enr
  { _                     :: Bit
  , rcc_apb1en_i2c3       :: Bit
  , rcc_apb1en_dac1       :: Bit
  , rcc_apb1en_pwr        :: Bit
  , _                     :: Bit
  , rcc_apb1en_dac2       :: Bit
  , rcc_apb1en_can        :: Bit
  , _                     :: Bit
  , rcc_apb1en_usb        :: Bit
  , rcc_apb1en_i2c2       :: Bit
  , rcc_apb1en_i2c1       :: Bit
  , rcc_apb1en_uart5      :: Bit
  , rcc_apb1en_uart4      :: Bit
  , rcc_apb1en_uart3      :: Bit
  , rcc_apb1en_uart2      :: Bit
  , _                     :: Bit
  , rcc_apb1en_spi3       :: Bit
  , rcc_apb1en_spi2       :: Bit
  , _                     :: Bits 2
  , rcc_apb1en_wwdg       :: Bit
  , _                     :: Bits 5
  , rcc_apb1en_tim7       :: Bit
  , rcc_apb1en_tim6       :: Bit
  , _                     :: Bit
  , rcc_apb1en_tim4       :: Bit
  , rcc_apb1en_tim3       :: Bit
  , rcc_apb1en_tim2       :: Bit
  }
|]

regRCC_APB1ENR :: BitDataReg RCC_APB1ENR
regRCC_APB1ENR = mkBitDataRegNamed (rcc_periph_base + 0x1C) "rcc_apb1enr"

[ivory|
 bitdata RCC_APB2ENR :: Bits 32 = rcc_apb2enr
  { _                     :: Bits 11
  , rcc_apb2en_tim20      :: Bit
  , _                     :: Bit
  , rcc_apb2en_tim17      :: Bit
  , rcc_apb2en_tim16      :: Bit
  , rcc_apb2en_tim15      :: Bit
  , rcc_apb2en_spi4       :: Bit
  , rcc_apb2en_uart1      :: Bit -- USART1
  , rcc_apb2en_tim8       :: Bit
  , rcc_apb2en_spi1       :: Bit
  , rcc_apb2en_tim1       :: Bit
  , _                     :: Bits 10
  , rcc_apb2en_syscfg     :: Bit
  }
|]

regRCC_APB2ENR :: BitDataReg RCC_APB2ENR
regRCC_APB2ENR = mkBitDataRegNamed (rcc_periph_base + 0x18) "rcc_apb2enr"

-- APB Peripheral Reset Registers ----------------------------------------------

[ivory|
 bitdata RCC_APB1RSTR :: Bits 32 = rcc_apb1rstr
  { _                :: Bits 8
  , rcc_apb1rst_i2c3 :: Bit
  , rcc_apb1rst_i2c2 :: Bit
  , rcc_apb1rst_i2c1 :: Bit
  , _                :: Bits 21
  }
|]

regRCC_APB1RSTR :: BitDataReg RCC_APB1RSTR
regRCC_APB1RSTR = mkBitDataRegNamed (rcc_periph_base + 0x10) "rcc_apb1rstr"