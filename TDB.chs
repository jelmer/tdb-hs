{-
	Haskell bindings for TDB

	Copyright (C) Jelmer Vernooij <jelmer@samba.org> [2005..2008]

	** NOTE! The following LGPL license applies to the tdb
	** library. This does NOT imply that all of Samba is released
	** under the LGPL
	 
   	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
   	License as published by the Free Software Foundation; either
   	version 3 of the License, or (at your option) any later version.

   	This library is distributed in the hope that it will be useful,
   	but WITHOUT ANY WARRANTY; without even the implied warranty of
   	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   	Lesser General Public License for more details.

   	You should have received a copy of the GNU Lesser General Public
   	License along with this library; if not, write to the Free Software
   	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
-}
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <talloc.h>
#include <tdb.h>

-- TODO: throw exception if return codes are non-zero

module TDB (open, hashsize, close, reopen, startTransaction, commitTransaction, 
			cancelTransaction, name)
where
import Foreign.C.String
import Foreign.C
import Foreign
import Data.Binary

{#context lib = "tdb"#}
{#context prefix = "tdb"#}

{#enum TDB_ERROR as Error {underscoreToCase}#}

{#pointer *tdb_context as Context newtype#}

open :: String -> Int -> Int -> Int -> Int-> IO Context
open name hash_size tdb_flags flags mode = do 
	cname <- newCString name
	ctx <- {#call tdb_open#} cname (fromIntegral hash_size) (fromIntegral tdb_flags) (fromIntegral flags) (fromIntegral mode)
	return ctx

close :: Context -> IO ()
close ctx = do {#call tdb_close#} ctx
               return ()

hashsize :: Context -> Int
hashsize = fromIntegral . {#call pure tdb_hash_size#}

seqnum :: Context -> Int
seqnum = fromIntegral . {#call pure tdb_get_seqnum#}

{-
exists :: Context -> ByteString -> IO Bool
exists ctx key = do ret <- {#call tdb_exists#} ctx (toDataBlob key)
                    return (toBool ret)

store :: Context -> ByteString -> ByteString -> IO Bool
store ctx key val = do ret <- {#call tdb_store#} ctx (toDataBlob key) (toDataBlob val)
                    return (toBool ret)
-}

transact :: (Context -> IO CInt) -> Context -> IO Bool
transact fn ctx = do ret <- fn ctx; return (toBool ret)

startTransaction :: Context -> IO Bool
startTransaction = transact {#call tdb_transaction_start#}

commitTransaction :: Context -> IO Bool
commitTransaction = transact {#call tdb_transaction_commit#}

cancelTransaction :: Context -> IO Bool
cancelTransaction = transact {#call tdb_transaction_cancel#}

reopen :: Context -> IO ()
reopen ctx = do ret <- {#call tdb_reopen#} ctx
                return ()

name :: Context -> IO String
name = peekCString . {#call pure tdb_name#}
