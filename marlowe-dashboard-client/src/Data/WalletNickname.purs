module Data.WalletNickname
  ( WalletNickname
  , WalletNicknameError(..)
  , dual
  , fromFoldable
  , fromString
  , validator
  , toString
  ) where

import Prologue

import Control.Monad.Reader (class MonadAsk, asks)
import Data.Bounded.Generic (genericBottom, genericTop)
import Data.Enum (class BoundedEnum, class Enum)
import Data.Enum.Generic
  ( genericCardinality
  , genericFromEnum
  , genericPred
  , genericSucc
  , genericToEnum
  )
import Data.Foldable (class Foldable)
import Data.Generic.Rep (class Generic)
import Data.Set (Set)
import Data.Set as Set
import Data.Show.Generic (genericShow)
import Data.String (null)
import Data.String.Regex (Regex)
import Data.String.Regex as Regex
import Data.String.Regex.Flags (ignoreCase)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Validation.Semigroup (V(..))
import Polyform (Validator)
import Polyform.Dual as Dual
import Polyform.Validator (liftFnMV)
import Polyform.Validator.Dual (Dual)

data WalletNicknameError
  = Empty
  | ContainsNonAlphaNumeric
  | Exists

derive instance genericWalletNicknameError :: Generic WalletNicknameError _
derive instance eqWalletNicknameError :: Eq WalletNicknameError
derive instance ordWalletNicknameError :: Ord WalletNicknameError

instance semigroupWalletNicknameError :: Semigroup WalletNicknameError where
  append Empty _ = Empty
  append _ Empty = Empty
  append ContainsNonAlphaNumeric _ = ContainsNonAlphaNumeric
  append _ ContainsNonAlphaNumeric = ContainsNonAlphaNumeric
  append Exists Exists = Exists

instance boundedWalletNicknameError :: Bounded WalletNicknameError where
  bottom = genericBottom
  top = genericTop

instance enumWalletNicknameError :: Enum WalletNicknameError where
  succ = genericSucc
  pred = genericPred

instance boundedEnumWalletNicknameError :: BoundedEnum WalletNicknameError where
  cardinality = genericCardinality
  toEnum = genericToEnum
  fromEnum = genericFromEnum

instance showWalletNicknameError :: Show WalletNicknameError where
  show = genericShow

newtype WalletNickname = WalletNickname String

derive instance eqWalletNickname :: Eq WalletNickname
derive instance ordWalletNickname :: Ord WalletNickname
derive newtype instance showWalletNickname :: Show WalletNickname

nicknameRegex :: Regex
nicknameRegex = unsafeRegex "^[a-z0-9]+$" ignoreCase

fromFoldable :: forall f. Foldable f => f String -> Set WalletNickname
fromFoldable = Set.map WalletNickname <<< Set.fromFoldable

fromString
  :: Set WalletNickname -> String -> Either WalletNicknameError WalletNickname
fromString used s
  | null s = Left Empty
  | Set.member (WalletNickname s) used = Left Exists
  | Regex.test nicknameRegex s = Right $ WalletNickname s
  | otherwise = Left ContainsNonAlphaNumeric

toString :: WalletNickname -> String
toString (WalletNickname s) = s

-------------------------------------------------------------------------------
-- Polyform adapters
-------------------------------------------------------------------------------

validator
  :: forall m
   . MonadAsk (Set WalletNickname) m
  => Validator m WalletNicknameError String WalletNickname
validator = liftFnMV \s -> asks \used -> V $ fromString used s

dual
  :: forall m
   . MonadAsk (Set WalletNickname) m
  => Dual m WalletNicknameError String WalletNickname
dual = Dual.dual validator (pure <<< toString)
