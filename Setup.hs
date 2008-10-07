#!/usr/bin/env runhaskell

import System (system, ExitCode)

import Distribution.Simple
import Distribution.PackageDescription

-- for the argument types of the `postInst' hook
import Distribution.Simple.LocalBuildInfo

main = defaultMain
