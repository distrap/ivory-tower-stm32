{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Ivory.Tower.Test.TaskTest
  ( task_simple_per
  , task_simple_per_emitter
  , task_simple_per_reader
  , tower_simple_per_tasks
  ) where

import Ivory.Language
import Ivory.Stdlib
import Ivory.Tower

task_simple_per :: Task p ()
task_simple_per = do
  ctr <- taskLocal "counter"
  lasttime <- taskLocal "lasttime"
  p <- timerEvent (Milliseconds 100)

  handle p "periodic" $ \timeRef -> do
    deref timeRef >>= store lasttime
    deref ctr >>= \(c :: Sint32) -> store ctr (c + 1)

task_simple_per_emitter :: ChannelSource (Stored Sint32) -> Task p ()
task_simple_per_emitter c = do
  e <- withChannelEmitter c "simple_emitter"
  p <- timerEvent (Milliseconds 20)
  handle p "emit_at_periodic" $ \timeRef -> do
    itime <- deref timeRef
    time <- assign (castWith 0 (toIMicroseconds itime))
    emitV_ e time


task_simple_per_reader :: ChannelSink (Stored Sint32) -> Task p ()
task_simple_per_reader c = do
  r <- withChannelReceiver c "simple_receiver"
  p <- timerEvent (Milliseconds 20)
  lastgood <- taskLocalInit "lastgood" (ival false)
  lastgot  <- taskLocal "lastgot"
  handle p "rx_at_periodic" $ \_ -> do
    (s,v) <- receiveV r
    store lastgood s
    when s $ store lastgot v

tower_simple_per_tasks :: Tower p ()
tower_simple_per_tasks = do
  task "simple_per" task_simple_per
  c <- channel
  task "simple_per_emitter" (task_simple_per_emitter (src c))
  task "simple_per_reader" (task_simple_per_reader (snk c))

