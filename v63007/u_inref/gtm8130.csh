#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#
set DOLLAR = '$' # because tcsh

echo '# The %GSEL utility now silently ignores any subscript in the search string and throws a non-fatal error if the input contains an invalid character'
echo '# Previously, %GSEL would remove invalid characters and then perform the search'
echo '# This could cause problems if a subscript was present because the utility removed "(" and ")" from the search pattern but not what was between them'
echo '# This change also applies to %GCE, %GD, %GO, and %GSE which use GD^%GSEL to search for globals'
echo '# In addition, when used interactively, it attempts to preserve the original I/O state of the caller; previously it tended to leave that state disrupted'

echo '# This does not test the I/O state disruption'

$gtm_tst/com/dbcreate.csh mumps

# fill the database with a bunch of globals
$gtm_dist/mumps -run %XCMD 'for i=0:1:25 set g="^"_$char(97+i)_"="_i s @g'
$gtm_dist/mumps -run %XCMD 'set g="^a" for i=1:1:10 set g=g_"a" set @g=i'
$gtm_dist/mumps -run %XCMD 'set g="^b(" for i=1:1:10 set g2=g_i_")" set @g2=i set g=g_i_","'

echo '# Testing GSEL - cat of commands file'
cat >> ydbcmdGSEL << xx
do ^%GSEL
b("thisIsNotASub")
b@d
a("b@dsub")
*("thisShouldBeIgnored")

zwrite %ZG
xx
cat ydbcmdGSEL
$gtm_dist/mumps -direct < ydbcmdGSEL

echo '# Testing GCE - cat of commands file'
cat >> ydbcmdGCE << xx
do ^%GCE
b("thisIsNotASub")
b@d
a("b@dsub")

0
changed



xx
cat ydbcmdGCE
$gtm_dist/mumps -direct < ydbcmdGCE

echo '# Testing GD - cat of commands file'
cat >> ydbcmdGD << xx
do ^%GD
b("thisIsNotASub")
b@d
a("b@dsub"):d
*("thisShouldBeIgnored")

xx
cat ydbcmdGD
$gtm_dist/mumps -direct < ydbcmdGD

echo '# Testing GO - cat of commands file'
cat >> ydbcmdGO << xx
do ^%GO
b("thisIsNotASub")
b@d
a("b@dsub")
*("thisShouldBeIgnored")

ZWR HEADER
ZWR
out.zwr
xx
cat ydbcmdGO
$gtm_dist/mumps -direct < ydbcmdGO

echo '# Testing GSE - cat of commands file'
cat >> ydbcmdGSE << xx
do ^%GSE

b("thisIsNotASub")
b@d
a("b@dsub")
*("thisShouldBeIgnored")

0

xx
cat ydbcmdGSE
$gtm_dist/mumps -direct < ydbcmdGSE

$gtm_tst/com/dbcheck.csh
