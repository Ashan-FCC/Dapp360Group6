{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables  #-}
module Main where

import StockPrices.App (runApp)

main :: IO ()
main = do
  _ <- runApp
  putStrLn "Finished"
