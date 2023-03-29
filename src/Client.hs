{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Werror=redundant-constraints #-}

module Client where

import Servant.API
import Servant.Client.Core
import Servant.Client.Generic

type EventId = Int
data EventClient route = EventClient

type ThingsForEventRoute =
    "events"
    :> Capture "event" Int
    :> "things"
    :> Get '[JSON] [Int]

class Monad m => EventClientMonad m where
  {-# MINIMAL getEventClient #-}
  getEventClient :: m (EventClient (AsClientT m))

  thingsForEvent :: Client m ThingsForEventRoute
  thingsForEvent _ = undefined

things :: EventClientMonad m => EventId -> m [Int]
things eventId = thingsForEvent eventId

-- class Thingy m where
class Monad m => Thingy m where
  thingies :: EventId -> m [Int]

-- instance EventClientMonad m => Thingy m where
instance (Monad m, EventClientMonad m) => Thingy m where
  thingies eventId = things eventId

-- Begining with ghc-9.2.3 this module fails to compile with the following error:
--       src/Client.hs error: [-Wredundant-constraints, -Werror=redundant-constraints]
--         • Redundant constraint: Monad m
--         • In the instance declaration for ‘Thingy m’
--         |
--      __ | instance (Monad m, EventClientMonad m) => Thingy m where
--         |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--
-- If we remove the redundant constraint, the module then also fails:
--    src/Client.hs: error:
--        • Could not deduce (Monad m)
--            arising from the superclasses of an instance declaration
--          from the context: EventClientMonad m
--            bound by the instance declaration at src/Client.hs
--          Possible fix:
--            add (Monad m) to the context of the instance declaration
--        • In the instance declaration for ‘Thingy m’
--      |
--   __ | instance EventClientMonad m => Thingy m where
--      |          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--
-- Using the commented out class and instance lines, the module compiles without
-- error.
