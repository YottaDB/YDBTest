#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# Test that $VIEW("GVFILE") works on database file name in the GLD SEGMENT in various cases'
echo '#   1) Contains full path and extension other than .dat. DEFAULT region'
echo '#   2) Contains full path and .dat extension. AREG region'
echo '#   3) Contains full path and no .dat extension. BREG region'
echo '#   4) Contains relative path and extension other than .dat. CREG region'
echo '#   5) Contains relative path and .dat extension. DREG region'
echo '#   6) Contains relative path and no .dat extension. EREG region'
echo '#   7) Contains full path using env var that is defined. FREG region'
echo '#   8) Contains full path using env var that is not defined. GREG region'
echo '#   9) Contains remote host/path without @ syntax (to use GT.CM GNP server). HREG region'
echo '#  10) Contains local  host/path using @ syntax (to use GT.CM GNP server). IREG region'

setenv ydb_gbldir yottadb.gld
setenv validenvvar "$PWD"

$ydb_dist/yottadb -run GDE << GDE_EOF >& gde.out
change -segment DEFAULT -file=$PWD/yottadb.mydat
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=$PWD/a.dat
add -name b -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=$PWD/b
add -name c -region=creg
add -region creg -dyn=cseg
add -segment cseg -file=c.mydat
add -name d -region=dreg
add -region dreg -dyn=dseg
add -segment dseg -file=d.dat
add -name e -region=ereg
add -region ereg -dyn=eseg
add -segment eseg -file=e
add -name f -region=freg
add -region freg -dyn=fseg
add -segment fseg -file=\$validenvvar/f.dat
add -name g -region=greg
add -region greg -dyn=gseg
add -segment gseg -file=\$invalidenvvar/g.dat
add -name h -region=hreg
add -region hreg -dyn=hseg
add -segment hseg -file=REMOTEHOST:h.dat
add -name i -region=ireg
add -region ireg -dyn=iseg
add -segment iseg -file=@LOCALHOST:i.dat
GDE_EOF

echo '# Also test that $VIEW("GVFILE") does not need database file to exist for it to work. So skip dbcreate.csh'

$ydb_dist/yottadb -run ydb709

