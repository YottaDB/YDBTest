#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

#
# the script checks for MUPIP integ errors.
# if called without argument it checks for DBBTUWRNG errors along with one another error specified by the caller
# the loop runs twice to ensure the first integ command doesn't fix the integ issue
# the caller should specify the kind of error to check thro' env. var mupip_err_chk
# if called with argument (e.g "warn" or "nowarn") then it checks for MUTNWARN error
# the caller should specify the value of the curr_tn to be set thro' env.var curval
# we also use a variable "repatflag" to ensure the same kind of integ happens twice as we check whether the first integ has fixed the error or not.
#
if ( "" == $1 ) then
	foreach values ("-region DEFAULT" "-file mumps.dat")
	set repeatflag="TRUE"
	runtwice:
	$MUPIP integ $values >&! integ.out
	set errcnt=`$grep -E "DBBTUWRNG|$mupip_err_chk" integ.out|wc -l`
	cat integ.out
	if ( 2 != $errcnt) then
		# this extra if condn is added now to cater to the change in test plan regarding KILLIP warnings
		if ( ("YDB-W-MUKILLIP" == "$mupip_err_chk") && ("FALSE" == "$repeatflag") && ("-file mumps.dat" == "$values") ) then
			echo "PASS. Killip warning as expected got fixed"
		else
	        	echo "TEST-E-ERROR. DBBTUWRNG $mupip_err_chk expected,but din't"
		endif
	else
		echo "PASS did get DBBTUWRNG $mupip_err_chk messages"
	endif
	if ( "FALSE" != $repeatflag ) then
	        set repeatflag="FALSE"
	        goto runtwice
	endif
	end
else
	$DSE change -fileheader -current_tn=$curval -warn_max_tn=$maxtnval
	$MUPIP integ -reg DEFAULT >&! mutnwarn.out
	cat mutnwarn.out
	if ( ( 0 == `grep "MUTNWARN" mutnwarn.out|wc -l`) && ($1 == "warn") ) then
		echo "TEST-E-ERROR. MUTNWARN expected but got none"
	else if ( ( 1 == `grep "MUTNWARN" mutnwarn.out|wc -l`) && ($1 == "nowarn") ) then
		echo "TEST-E-ERROR. MUTNWARN not expected but got one"
	else
		echo "PASS for $curval displaying a $1"
	endif
endif
rm -f mutnwarn.out
#
