{-# LANGUAGE OverloadedStrings #-}

module Main where

-- Adapted from https://github.com/lucasdicioccio/http2-client/blob/master/examples/SimpleGet.lhs

import Control.Effect(runM)
import System.Log.Caster.FusedEffect.Logging

import Network.HTTP2.Client
import Network.HTTP2.Client.Helpers

import Network.HTTP2
import Data.Default.Class (def)
import Network.TLS as TLS
import Network.TLS.Extra.Cipher as TLS

clientActions :: Http2Client -> ClientIO ()
clientActions conn = do
  let fc = _incomingFlowControl conn
  lift $ _addCredit fc 10000000
  _ <- _updateWindow fc
  let requestHeaders = [
          (":method", "GET")
        , (":scheme", "https")
        , (":path", "?q=http2")
        , (":authority", "axon-server")
        ]
  _ <- withHttp2Stream conn $ \stream ->
    let initStream = headers stream requestHeaders (setEndHeader . setEndStream)
        resetPushPromises _ pps _ _ _ = _rst pps RefusedStream
        handler sfc _ = do
          waitStream stream sfc resetPushPromises >>= lift . print . fromStreamResult
    in StreamDefinition initStream handler
  lift $ putStrLn "done"
  _goaway conn NoError "https://github.com/lucasdicioccio/http2-client example"

main :: IO ()
main =
  do putStrLn "Hello, Haskell!"
     runM . runLogEffect $ do
       info "bliep"
     _ <- runClientIO $ do
       frameConn <- newHttp2FrameConnection "axon-server" 8124 Nothing
       runHttp2Client frameConn 8192 8192 [(SettingsInitialWindowSize,10000000)] defaultGoAwayHandler ignoreFallbackHandler clientActions
     return ()
