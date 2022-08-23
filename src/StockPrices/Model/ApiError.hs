{-# LANGUAGE DeriveGeneric, DeriveAnyClass  #-}
module StockPrices.Model.ApiError where

import Data.Aeson
import GHC.Generics (Generic)

newtype ApiError = ApiError {
  errors :: [String]
} deriving (Generic, Show, ToJSON)