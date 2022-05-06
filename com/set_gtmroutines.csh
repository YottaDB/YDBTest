#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# anyerror is unset at the beginning and set at the end of the code.
# This is done to counteract the effect of the -e flag added to com/submit_test.csh
# unsetting anyerror makes sure that exit status of a backquote expansion
# that evaluates an expression ((`expr "V900" \> "$set_gtmro_verno"`) && (`expr "V62000" \>= "$set_gtmro_verno"`)) is not propagated to $status
unset anyerror

#
# $1 - "M" or "UTF8"
#

# Added logic to solely set $gtmroutines to the value of $test_gtmroutines_preset if it is defined.
if ($?test_gtmroutines_preset) then
	setenv gtmroutines "$test_gtmroutines_preset"
	exit
endif

# Starting with V6.2-000, GT.M supports autorelink. It is enabled randomly in do_random_settings.csh by assigning a three-character
# string to $gtm_test_autorelink_dirs in do_random_settings.csh. Each character is either 1 or 0, meaning that the directory by that
# index in $gtmroutines constructed below either gets or does not an asterisk after it. So, if more than three directories are used
# to construct $gtmroutines in this script, a corresponding change is required in do_random_settings.csh.

set set_gtmro_verno = "${gtm_exe:h:t}"

if ((`expr "V900" \> "$set_gtmro_verno"`) && (`expr "V62000" \>= "$set_gtmro_verno"`)) then
	set set_gtmro_randnums = (0 0)
else if ($?gtm_test_autorelink_dirs) then
	if (2 != `printf $gtm_test_autorelink_dirs | wc -c`) then
		set tmp = `echo "$gtm_test_autorelink_dirs" | sed 's/\(.\)/\1 /g'`
		if ($tmp[1]) then
			set set_gtmro_randnums = (1 1)
		else
			set set_gtmro_randnums = (0 0)
		endif
	else
		set set_gtmro_randnums = `echo "$gtm_test_autorelink_dirs" | sed 's/\(.\)/\1 /g'`
	endif
else
	set set_gtmro_randnums = (0 0)
endif

@ i = 1
while ($i <= 2)
	if ($set_gtmro_randnums[$i]) then
		set star${i} = "*"
	else
		set star${i} = ""
	endif
	@ i++
end

set chset = ${1:au:as/-//}
if ( "$chset" !~ {M,UTF8} ) then
	echo "SETGTMROUTINES-E-INVALID : $1 not a valid parameter. Should be either M or UTF8"
	exit -1
endif

set gtm_routines_var = ".${star1}("

if (-e $gtm_tst/$tst/inref) then
	set gtm_routines_var = "${gtm_routines_var}${gtm_tst}/$tst/inref"
endif

set gtm_routines_var = "$gtm_routines_var $gtm_tst/com ."

if (-e $gtm_com/gtmji) then
	set gtm_routines_var = "$gtm_routines_var $gtm_com/gtmji"
endif

set gtm_routines_var = "${gtm_routines_var})"

set utf8 = ""
if ($chset == "UTF8") then
	set utf8 = "/utf8"
endif
if (-d ${gtm_exe}/plugin/o${utf8} && -d ${gtm_exe}/plugin/r) then
	set plugrtns = " ${gtm_exe}/plugin/o${utf8}${star2}(${gtm_exe}/plugin/r)"
else
	set plugrtns = ""
endif
# If _ydbposix.so exists, use that ahead of _POSIX.m (to avoid permission errors while trying to create plugin/o/_POSIX.o)
if (-e ${gtm_exe}/plugin/o${utf8}/_ydbposix.so) then
	set plugrtns = " ${gtm_exe}/plugin/o${utf8}/_ydbposix.so $plugrtns"
endif
set exedir = "$gtm_exe${utf8}${star2}${plugrtns}"
set gtm_routines_var = "${gtm_routines_var} ${exedir}"

setenv gtmroutines "$gtm_routines_var"
set anyerror
