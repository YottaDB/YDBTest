#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
Issue description says:

> This is an issue that was reported at https://groups.google.com/g/comp.lang.mumps/c/ziaED-gM8wM?pli=1
> Based on that report, I was able to come up with the following
> simple test case that demonstrates the issue.
>
> While trying this test case out with upstream releases (GT.M
> versions), I noticed that the above test fails similarly in
> all upstream releases except the latest GT.M V7.0-004. It
> turns out to have been fixed there.
>
> Release notes http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE270421 says:
>
>> GT.M handles \$ORDER(), \$ZPREVIOUS(), \$QUERY(), \$NEXT(),
>> and MERGE operations which traverse subscript-level mappings
>> correctly. Previously, these operations could return gvns
>> which should have been excluded by the global directory. In
>> the case of MERGE, the target could contain data from excluded
>> subtrees. (GTM-DE270421)
CAT_EOF
echo ''

unset ydb_gbldir
unset ydb_routines

setenv gtmroutines ". $ydb_dist"

setenv gtmgbldir "1reg.gld"
rm -f $gtmgbldir
$ydb_dist/mumps -run GDE >& gde1.out << GDE1_EOF
change -segment DEFAULT -file=mumps.dat
GDE1_EOF

setenv gtmgbldir "2reg.gld"
rm -f $gtmgbldir
$ydb_dist/mumps -run GDE >& gde2.out << GDE2_EOF
change -segment DEFAULT -file=mumps.dat
add -name a(2) -region=AREG
add -region AREG -dyn=ASEG
add -segment ASEG -file=a.dat
change -region DEFAULT -stdnullcoll
change -region AREG -stdnullcoll
GDE2_EOF

rm -f mumps.dat a.dat
$ydb_dist/mupip create >& mupip_create.out

echo '# This is an automated test of the test case described at'
echo '# https://gitlab.com/YottaDB/DB/YDB/-/issues/960#description.'
echo '# The output expected below is g="^a(2,1)".'
echo '# Before YDB#960, one used to instead see a GVUNDEF error.'

$ydb_dist/mumps -run %XCMD 'set $zgbldir="2reg.gld" set ^a(2,1)=21'
$ydb_dist/mumps -run %XCMD 'set $zgbldir="1reg.gld" set ^a(2,2)=22'
$ydb_dist/mumps -run %XCMD 'set $zgbldir="2reg.gld" set g="^a" for  set g=$query(@g) quit:g=""  zwrite g set x=@g'
