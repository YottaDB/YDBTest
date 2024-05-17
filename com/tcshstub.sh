#!/usr/bin/bash --norc
#The line above must use bash in order to repeat quoted args exactly to subcommand

# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries. All rights reserved.
# This source code contains the intellectual property of its copyright holder(s), and is made available
# under a license.  If you do not know the terms of the license, please stop and do not read further.

#This script acts like /usr/local/bin/tcsh but removes a -f from the command line
#so that nested debugging works if $__cshdebug exists
[ "$1" == "-f" -a -v __cshdebug ] && shift
exec -a /usr/local/bin/tcsh /usr/bin/tcsh "$@"
