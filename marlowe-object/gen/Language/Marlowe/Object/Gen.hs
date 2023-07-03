{-# LANGUAGE GADTs #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Language.Marlowe.Object.Gen where

import Control.Lens (Ixed (ix), (.~))
import Control.Monad (replicateM)
import qualified Data.ByteString as BS
import Data.Foldable (Foldable (fold))
import Data.Function ((&))
import Gen.Cardano.Api.Typed (genAddressShelley)
import Language.Marlowe.Object.Link (LinkError (..))
import Language.Marlowe.Object.Types
import Spec.Marlowe.Semantics.Arbitrary ()
import Test.QuickCheck hiding (label)
import Test.QuickCheck.Hedgehog (hedgehog)
import Test.QuickCheck.Instances ()

instance Arbitrary ObjectBundle where
  arbitrary = ObjectBundle <$> arbitrary
  shrink = genericShrink

instance Arbitrary LinkError where
  arbitrary =
    oneof
      [ UnknownSymbol <$> arbitrary
      , TypeMismatch <$> arbitrary <*> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary SomeObjectType where
  arbitrary =
    elements
      [ SomeObjectType ValueType
      , SomeObjectType ObservationType
      , SomeObjectType ContractType
      , SomeObjectType PartyType
      , SomeObjectType TokenType
      , SomeObjectType ActionType
      ]

instance Arbitrary LabelledObject where
  arbitrary = do
    label :: Label <- arbitrary
    type_ <- arbitrary
    case type_ of
      SomeObjectType ValueType -> LabelledObject label ValueType <$> arbitrary
      SomeObjectType ObservationType -> LabelledObject label ObservationType <$> arbitrary
      SomeObjectType ContractType -> LabelledObject label ContractType <$> arbitrary
      SomeObjectType PartyType -> LabelledObject label PartyType <$> arbitrary
      SomeObjectType TokenType -> LabelledObject label TokenType <$> arbitrary
      SomeObjectType ActionType -> LabelledObject label ActionType <$> arbitrary
  shrink LabelledObject{..} =
    fold
      [ [LabelledObject{label = label', ..} | label' <- shrink label]
      , case type_ of
          ValueType -> [LabelledObject{value = value', ..} | value' <- shrink value]
          ObservationType -> [LabelledObject{value = value', ..} | value' <- shrink value]
          ContractType -> [LabelledObject{value = value', ..} | value' <- shrink value]
          PartyType -> [LabelledObject{value = value', ..} | value' <- shrink value]
          TokenType -> [LabelledObject{value = value', ..} | value' <- shrink value]
          ActionType -> [LabelledObject{value = value', ..} | value' <- shrink value]
      ]

instance Arbitrary Object where
  arbitrary =
    oneof
      [ ValueObject <$> arbitrary
      , ObservationObject <$> arbitrary
      , ContractObject <$> arbitrary
      , PartyObject <$> arbitrary
      , TokenObject <$> arbitrary
      , ActionObject <$> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary Label where
  arbitrary = Label <$> arbitrary
  shrink = genericShrink

instance Arbitrary Contract where
  arbitrary = sized \size ->
    if size <= 0
      then
        oneof -- Why not simply close? Because there are tests that effectively do this: `arbitrary `suchThat` (/= Close), which
          [ Pay <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary <*> pure Close
          , If <$> arbitrary <*> resize (size `quot` 2) arbitrary <*> pure Close
          , When [Case (Notify TrueObs) Close] <$> arbitrary <*> arbitrary
          , Let <$> arbitrary <*> arbitrary <*> pure Close
          , Assert <$> arbitrary <*> pure Close
          , pure Close
          , ContractRef <$> arbitrary
          ]
      else
        frequency
          [
            ( 4
            , Pay
                <$> arbitrary
                <*> arbitrary
                <*> arbitrary
                <*> arbitrary
                <*> resize (pred size) arbitrary
            )
          ,
            ( 2
            , If <$> arbitrary <*> resize (size `quot` 2) arbitrary <*> resize (size `quot` 2) arbitrary
            )
          ,
            ( 3
            , do
                -- Since the size of a `When` is O(c*n) where `c` is the number of cases and `n` is the size of sub
                -- contracts, we need to use `c ~ sqrt size` and `n = size / c` to create a contract that is an appropriate size.
                let maxCases = floor $ sqrt @Double $ fromIntegral size
                numCases <- chooseInt (0, maxCases)
                let numSubContracts = succ numCases
                let subContractSize = size `quot` numSubContracts
                When
                  <$> vectorOf numCases (resize subContractSize arbitrary)
                  <*> arbitrary
                  <*> resize subContractSize arbitrary
            )
          , (4, Let <$> arbitrary <*> arbitrary <*> resize (pred size) arbitrary)
          , (1, Assert <$> arbitrary <*> resize (pred size) arbitrary)
          , (1, pure Close)
          , (1, ContractRef <$> arbitrary)
          ]
  shrink = genericShrink

instance Arbitrary Case where
  arbitrary =
    oneof
      [ Case <$> arbitrary <*> arbitrary
      , MerkleizedCase <$> arbitrary <*> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary Action where
  arbitrary =
    oneof
      [ Deposit <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
      , Choice <$> arbitrary <*> arbitrary
      , Notify <$> arbitrary
      , ActionRef <$> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary Value where
  arbitrary = sized \size ->
    if size <= 0
      then leaves
      else
        oneof
          [ leaves
          , resize (pred size) $ NegValue <$> arbitrary
          , resize (size `quot` 2) $ AddValue <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ SubValue <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ MulValue <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ DivValue <$> arbitrary <*> arbitrary
          , resize (size `quot` 3) $ Cond <$> arbitrary <*> arbitrary <*> arbitrary
          ]
    where
      leaves =
        frequency
          [ (4, AvailableMoney <$> arbitrary <*> arbitrary)
          , (7, Constant <$> arbitrary)
          , (5, ChoiceValue <$> arbitrary)
          , (5, ValueRef <$> arbitrary)
          , (3, pure TimeIntervalStart)
          , (3, pure TimeIntervalEnd)
          , (4, UseValue <$> arbitrary)
          ]
  shrink = genericShrink

instance Arbitrary Observation where
  arbitrary = sized \size ->
    if size <= 0
      then leaves
      else
        oneof -- size > 0 produces compound observations.
          [ leaves
          , resize (size `quot` 2) $ AndObs <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ OrObs <$> arbitrary <*> arbitrary
          , resize (pred size) $ NotObs <$> arbitrary
          , resize (size `quot` 2) $ ValueGE <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ ValueGT <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ ValueLT <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ ValueLE <$> arbitrary <*> arbitrary
          , resize (size `quot` 2) $ ValueEQ <$> arbitrary <*> arbitrary
          ]
    where
      leaves =
        frequency
          [ (8, ChoseSomething <$> arbitrary)
          , (5, ObservationRef <$> arbitrary)
          , (5, pure TrueObs)
          , (5, pure FalseObs)
          ]
  shrink = genericShrink

instance Arbitrary Party where
  arbitrary =
    oneof
      [ Address <$> arbitrary
      , Role <$> arbitrary
      , PartyRef <$> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary ShelleyAddress where
  arbitrary = hedgehog $ ShelleyAddress <$> genAddressShelley

instance Arbitrary Payee where
  arbitrary =
    oneof
      [ Party <$> arbitrary
      , Account <$> arbitrary
      ]
  shrink = genericShrink

instance Arbitrary ChoiceId where
  arbitrary = ChoiceId <$> arbitrary <*> arbitrary
  shrink = genericShrink

instance Arbitrary ValueId where
  arbitrary = ValueId <$> arbitrary
  shrink = genericShrink

instance Arbitrary TokenName where
  arbitrary = TokenName <$> arbitrary
  shrink = genericShrink

instance Arbitrary Timeout where
  arbitrary = fromCoreTimeout <$> arbitrary
  shrink = genericShrink

instance Arbitrary Bound where
  arbitrary = Bound <$> arbitrary <*> arbitrary
  shrink = genericShrink

instance Arbitrary ContractHash where
  arbitrary = ContractHash . BS.pack <$> replicateM 32 arbitrary
  shrink = fmap ContractHash . shrinkFixedLengthByteString . unContractHash

instance Arbitrary CurrencySymbol where
  arbitrary = CurrencySymbol . BS.pack <$> replicateM 32 arbitrary
  shrink = fmap CurrencySymbol . shrinkFixedLengthByteString . unCurrencySymbol

instance Arbitrary Token where
  arbitrary =
    oneof
      [ Token <$> arbitrary <*> arbitrary
      , TokenRef <$> arbitrary
      ]
  shrink = genericShrink

shrinkFixedLengthByteString :: BS.ByteString -> [BS.ByteString]
shrinkFixedLengthByteString bs = do
  i <- [0 .. BS.length bs - 1]
  let originalByte = BS.index bs i
  newByte <- shrink originalByte
  pure $ bs & ix i .~ newByte
