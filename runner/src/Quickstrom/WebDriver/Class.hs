{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE KindSignatures #-}

module Quickstrom.WebDriver.Class where

import qualified Data.Aeson as JSON
import Data.String (String)
import Quickstrom.Browser
import Quickstrom.Element (Element, Selector)
import Quickstrom.LogLevel
import Quickstrom.Prelude

data WebDriverOptions = WebDriverOptions
  { webDriverBrowser :: Browser,
    webDriverBrowserBinary :: Maybe FilePath,
    webDriverLogLevel :: LogLevel,
    webDriverHost :: Text,
    webDriverPort :: Int,
    webDriverPath :: FilePath,
    webDriverAdditionalOptions :: (Set Text)
  }

class Monad m => WebDriver (m :: Type -> Type) where
  getActiveElement :: m Element
  isElementEnabled :: Element -> m Bool
  getElementTagName :: Element -> m Text
  elementClick :: Element -> m ()
  elementSendKeys :: Text -> Element -> m ()
  findAll :: Selector -> m [Element]
  navigateTo :: Text -> m ()
  runScript :: JSON.FromJSON r => Text -> [JSON.Value] -> m r
  catchResponseError :: m a -> (WebDriverResponseError -> IO a) -> m a
  inNewPrivateWindow :: WebDriverOptions -> m a -> m a

instance WebDriver m => WebDriver (ReaderT e m) where
  getActiveElement = lift getActiveElement
  isElementEnabled = lift . isElementEnabled
  getElementTagName = lift . getElementTagName
  elementClick = lift . elementClick
  elementSendKeys keys = lift . elementSendKeys keys
  findAll = lift . findAll
  navigateTo = lift . navigateTo
  runScript s = lift . runScript s
  catchResponseError ma f = ReaderT (\r -> catchResponseError (runReaderT ma r) f)
  inNewPrivateWindow opts (ReaderT ma) = ReaderT (inNewPrivateWindow opts . ma)

data WebDriverResponseError = WebDriverResponseError Text
  deriving (Show, Generic)

instance Exception WebDriverResponseError

data WebDriverOtherError = WebDriverOtherError Text
  deriving (Show, Generic)

instance Exception WebDriverOtherError
