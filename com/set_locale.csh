#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# this file has to be source'd in each test/subtest that uses multi-byte characters for dspmbyte
#
# the argument "norecurse" is only an internal argument (between gtm_test_setunicode.csh and set_locale.csh),
# no other script should use the "norecurse" option.

set dspmbyte=utf8

if (! $?gtm_chset) exit
if ("M" == "$gtm_chset") exit

#in case the test overrides
if ((! $?gtm_test_dbdata) && ("norecurse" != "$1")) then
	set randnumber = `$gtm_tst/com/genrandnumbers.csh 1 1 100`
	source $gtm_tst/com/gtm_test_setunicode.csh $randnumber norecurse
endif

setenv LANG C
unsetenv LC_ALL
# depending on the list of locales configured, locale -a might be considered a binary output. (on scylla currently)
# grep needs -a option to process the output as text to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on the non-linux servers we have.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif

# If this is alpine, the UTF8 locale looks different so just set it
if (("linux" == "$gtm_test_osname") && ("alpine" == "$gtm_test_linux_distrib")) then
	set utflocale = "C.UTF8"  # Verify this is the one to use ##ALPINE_TODO##
else
	set utflocale = `locale -a | grep $binaryopt -iE 'en_us\.utf.?8$' | head -n 1`  #BYPASSOK grep head
endif

setenv LC_CTYPE $utflocale
setenv LC_COLLATE C # because regular unix commands like ls, sort etc. rely on LC_COLLATE to be "C" for sorting names

# ??? other platforms???
# note down what the settings are in some file in the output directory

