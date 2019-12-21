module Main where

import Control.Effect(runM)
import System.Log.Caster.FusedEffect.Logging

main :: IO ()
main =
  do putStrLn "Hello, Haskell!"
     runM . runLogEffect $ do
       info "bliep"
