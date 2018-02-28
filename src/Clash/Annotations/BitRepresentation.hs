{-|
Copyright  :  (C) 2017, Google Inc.
License    :  BSD2 (see the file LICENSE)
Maintainer :  Christiaan Baaij <christiaan.baaij@gmail.com>

This module houses annotations allowing custom bit representations for (custom)
data types.
-}

{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Clash.Annotations.BitRepresentation
 ( DataRepr(..)
 , DataReprAnn(..)
 , ConstrRepr(..)
 , TypeName(..)
 ) where

import qualified Language.Haskell.TH.Syntax as TH

import Data.Data (Data)
import Data.Typeable (Typeable)

type BitMask  = Integer
type Value    = Integer
type Size     = Integer

type FieldAnn = BitMask

data TypeName = TN TH.Name [TypeName]
              -- ^ Type name with a number of types as arguments
              | TT TH.Name
              -- ^ Type name terminal; equivalent to TN with an empty list
                 deriving (Show, Data, Typeable)

deriving instance TH.Lift TypeName

-- instances we need to derive Lift TypeName
-- NOTE: Don't import these from Language.Haskell.TH.Instances
--       Doing so will also import `instance Lift Exp`
--       And that changes certain TH mistakes from compile to run time errors.
deriving instance TH.Lift TH.Name
deriving instance TH.Lift TH.OccName
deriving instance TH.Lift TH.NameFlavour
deriving instance TH.Lift TH.ModName
deriving instance TH.Lift TH.NameSpace
deriving instance TH.Lift TH.PkgName

-- | Type annotation for inline annotations. Example usage:
--
-- @
-- data Color = R | G | B
-- {-# ANN module (DataReprAnn (TT ''Color) 2 [...]) #-}
-- @
--
-- To annotate composed types, use TN. For example, if we want to annotate
-- `Maybe Color`:
--
-- @
-- {-# ANN module ( DataReprAnn
--                    (TN ''Maybe [TT ''Color])
--                    2
--                    [...] ) #-}
-- @
data DataReprAnn =
  DataReprAnn
    TypeName
    -- ^ Type this annotation is for
    Size
    -- ^ Size of type
    [ConstrRepr]
    -- ^ Constructors
      deriving (Show, Data, Typeable)

-- | Type annotation for annotations specified in a separate file, interpreted
-- by Clash using '-fclash-custom-reprs <path>'.
--
-- @
-- data Color = R | G | B
-- colorAnn = DataRepr 2 [...] :: DataRepr Color
-- @
--
-- To annotate composed types, simply extend /colorAnn/s type. For example, if
-- we want to annotate `Maybe Color`:
--
-- @
-- data Color = R | G | B
-- colorAnn = DataRepr 2 [...] :: DataRepr (Maybe Color)
-- @

data DataRepr a =
  DataRepr
    Size
    -- ^ Size of type
    [ConstrRepr]
    -- ^ Constructors
      deriving (Show, Data, Typeable)

-- | Constructor annotation.
data ConstrRepr =
  ConstrRepr
    TH.Name
    -- ^ Constructor name
    BitMask
    -- ^ Bits relevant for this constructor
    Value
    -- ^ data & mask should be equal to..
    [FieldAnn]
    -- ^ Masks for fields. Indicates where fields are stored.
      deriving (Show, Data, Typeable)
