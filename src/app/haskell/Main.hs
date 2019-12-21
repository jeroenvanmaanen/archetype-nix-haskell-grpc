module Main where

import Control.Concurrent
import Control.Effect
import Control.Monad
import Control.Monad.IO.Class
import System.Log.Caster.FusedEffect.Logging

main :: IO ()
main =
  do putStrLn "Hello, Haskell!"
     runM . runLogEffect $ do
       info "bliep"
