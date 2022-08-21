
{-# LANGUAGE DeriveGeneric  #-}
{-# LANGUAGE OverloadedStrings  #-}
module Main where
--import qualified Prelude as Prelude
import Network.Wreq (Options, defaults, param, header,getWith, asValue, responseBody,asJSON)
import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Map
import GHC.Generics (Generic)
import Control.Lens
import Data.Aeson (Value)
import Data.Map as Map
import Control.Monad (forM_)

data TranslateRsponse = TranslateRsponse {
 results :: [Quote],
 total :: Int,
 offset :: Int
}
 deriving (Show,Generic)

data Quote = Quote {
 date :: Text,
 open :: Float,
 high :: Float ,
 low :: Float ,
 close :: Float ,
 volume :: Float ,
 adjClose :: Float 
}
 deriving (Show,Generic)

instance FromJSON TranslateRsponse
instance FromJSON Quote


main :: IO ()
main = do
--sample for calling the function
  resp <-  getStockPrice "MSFT" "2022-08-18"
  print resp


stockOptions :: Text -> Text -> Options
stockOptions pSymbol pDate= defaults & header "X-RapidAPI-Key" .~ ["6fd3e0bae8msh6c11f25ca5950e0p188990jsn7dbf851d79eb"] & param "EndDateInclusive" .~ [pDate] 
  & param "StartDateInclusive" .~ [pDate] & param "Symbol" .~ [pSymbol]
getStockPrice :: Text -> Text -> IO Quote
getStockPrice stockSymbol stockDate = do
  response <-  getWith (stockOptions stockSymbol stockDate) "https://yahoofinance-stocks1.p.rapidapi.com/stock-prices"
  jsonResponse <- asJSON response
  pure( head(results (jsonResponse ^. responseBody)))
  --forM_  (results (jsonResponse ^. responseBody)) $ \q  -> do


 