{-
module Main where

import qualified MyLib (someFunc)

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  MyLib.someFunc
-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module Main where

import StockPrices.App (runApp)

main :: IO ()
main = do
  _ <- runApp
  putStrLn "Finished"
