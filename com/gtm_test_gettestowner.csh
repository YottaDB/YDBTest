#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set tst = "$1"
if (! $?gtm_tst) then
	source $gtm_test/T990/com/set_specific.csh
endif
# If the mail is to be sent to gglogs (i.e tests started by gtmtest, most probably weekend E_ALL), copy test assignment owner too
set testowner = ""
set testowner = `$tst_awk '{if ("'$tst'" == $1) { print $2 }}' $warn_tools/assignments*`
set vdate = `date +%Y%m%d`
set vacations = `$tst_awk '/##VACATION##/ { if($3 > '$vdate') {print $2}}' $warn_tools/assignments.tmp`
set onvacation = 1
foreach owner ($testowner)
	if !( "$vacations" =~ *$owner* ) set onvacation = 0 # At least one of the owners is not on vacation
end
if ($onvacation) then
	set secondary = `$tst_awk '/^'$tst'/ {print $3 ; exit}' $warn_tools/assignments`
	set testowner = "$testowner $secondary"
endif
set testowner = `echo $testowner | sed 's/ /,/'`

echo $testowner
