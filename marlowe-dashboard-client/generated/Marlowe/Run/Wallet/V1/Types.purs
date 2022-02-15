-- File auto generated by purescript-bridge! --
module Marlowe.Run.Wallet.V1.Types where

import Prelude

import Control.Lazy (defer)
import Data.Address (Address)
import Data.Argonaut (encodeJson, jsonNull)
import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Decode.Aeson ((</$\>), (</*\>), (</\>))
import Data.Argonaut.Decode.Aeson as D
import Data.Argonaut.Encode (class EncodeJson)
import Data.Argonaut.Encode.Aeson ((>$<), (>/\<))
import Data.Argonaut.Encode.Aeson as E
import Data.Generic.Rep (class Generic)
import Data.Lens (Iso', Lens', Prism', iso, prism')
import Data.Lens.Iso.Newtype (_Newtype)
import Data.Lens.Record (prop)
import Data.Map as Map
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.PaymentPubKeyHash (PaymentPubKeyHash)
import Data.Show.Generic (genericShow)
import Data.Tuple.Nested ((/\))
import Data.WalletId (WalletId)
import Type.Proxy (Proxy(Proxy))

newtype WalletInfo = WalletInfo
  { walletId :: WalletId
  , pubKeyHash :: PaymentPubKeyHash
  , address :: Address
  }

derive instance Eq WalletInfo

instance Show WalletInfo where
  show a = genericShow a

instance EncodeJson WalletInfo where
  encodeJson = defer \_ -> E.encode $ unwrap >$<
    ( E.record
        { walletId: E.value :: _ WalletId
        , pubKeyHash: E.value :: _ PaymentPubKeyHash
        , address: E.value :: _ Address
        }
    )

instance DecodeJson WalletInfo where
  decodeJson = defer \_ -> D.decode $
    ( WalletInfo <$> D.record "WalletInfo"
        { walletId: D.value :: _ WalletId
        , pubKeyHash: D.value :: _ PaymentPubKeyHash
        , address: D.value :: _ Address
        }
    )

derive instance Generic WalletInfo _

derive instance Newtype WalletInfo _

--------------------------------------------------------------------------------

_WalletInfo :: Iso' WalletInfo
  { walletId :: WalletId, pubKeyHash :: PaymentPubKeyHash, address :: Address }
_WalletInfo = _Newtype
