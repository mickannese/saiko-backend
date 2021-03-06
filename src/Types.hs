{-# LANGUAGE TemplateHaskell#-}
{-# LANGUAGE LambdaCase#-}
{-# LANGUAGE OverloadedStrings#-}

module Types where

import Data.Aeson
import Data.Time ( UTCTime )
import Data.Aeson.TH
import Control.Lens.TH
import Data.Text.Lazy hiding (drop)
import Data.ByteString.Lazy hiding (drop)

data Message = Msg { _Mtime :: UTCTime
                   , _Mbody :: Text
                   , _MuserName :: Text
                   , _Mchannel :: Text
                   } deriving (Eq, Show)

deriveJSON defaultOptions{fieldLabelModifier = drop 2} ''Message
makeLenses ''Message


data Channel = Channel { _channelName :: Text
                       , _channelId :: Maybe Int
                       } deriving (Show)

deriveJSON defaultOptions{fieldLabelModifier = drop 1} ''Channel
makeLenses ''Channel

data User = User { _username :: Text
                 , _userId :: Maybe Int
                 } deriving (Eq, Show)


deriveJSON defaultOptions{fieldLabelModifier = drop 1} ''User
makeLenses ''User