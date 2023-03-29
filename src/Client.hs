{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Werror=redundant-constraints #-}

module Client where

class Monad m => Event m where
  thingsForEvent :: m [Int]
  thingsForEvent = undefined

things :: Event m => m [Int]
things = thingsForEvent

-- class Thingy m where
class Monad m => Thingy m where
  thingies :: m [Int]

-- instance Event m => Thingy m where
instance (Monad m, Event m) => Thingy m where
  thingies = things

-- Begining with ghc-9.2.3 this module fails to compile with the following error:
--       src/Client.hs error: [-Wredundant-constraints, -Werror=redundant-constraints]
--         • Redundant constraint: Monad m
--         • In the instance declaration for ‘Thingy m’
--         |
--      __ | instance (Monad m, Event m) => Thingy m where
--         |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--
-- If we remove the redundant constraint, the module then also fails:
--    src/Client.hs: error:
--        • Could not deduce (Monad m)
--            arising from the superclasses of an instance declaration
--          from the context: Event m
--            bound by the instance declaration at src/Client.hs
--          Possible fix:
--            add (Monad m) to the context of the instance declaration
--        • In the instance declaration for ‘Thingy m’
--      |
--   __ | instance Event m => Thingy m where
--      |          ^^^^^^^^^^^^^^^^^^^
--
-- Using the commented out class and instance lines, the module compiles without
-- error.
