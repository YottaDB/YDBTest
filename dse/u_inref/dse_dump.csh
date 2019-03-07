#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
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

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

#create a global directory with two regions -- DEFAULT, REGX
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 2

# Set some global variables - to fill some blocks

$GTM << GTM_EOF
do ^createdb
halt
GTM_EOF

# Test the dse -dump command

echo "TEST DSE - DUMP COMMAND"

# dump with no block qualifier

$DSE << DSE_EOF

dump -he

DSE_EOF

# dump block zero, non existing and existing blocks

$DSE << DSE_EOF

dump -block=0
dump -block=97
dump -block=45

DSE_EOF

# dump consecutive blocks starting from block zero

$DSE << DSE_EOF

dump -bl=0 -count=1
dump -bl=0 -count=0

DSE_EOF

# dump the header of block zero
# dump the header_less information of block zero

$DSE << DSE_EOF

dump -header -block=0
dump -noheader -block=0

DSE_EOF

# try dumping the records of block zero

$DSE << DSE_EOF

dump -bl=0 -offset=0
dump -bl=0 -offset=10
dump -bl=0 -rec=1
dump -bl=0 -rec=1 -cou=2

DSE_EOF

# test header/noheader qualifiers

$DSE << DSE_EOF

dump -block=4 -header

DSE_EOF

# block 45 has only header information

$DSE << DSE_EOF

dump -block=45 -noheader

DSE_EOF

# fileheader with count

$DSE << DSE_EOF

dump -fileh -coun=2

DSE_EOF

# fileheaders with and without header options

$DSE << DSE_EOF

dump -file -noheader
dump -file -header

DSE_EOF

# dumping consecutive blocks with and without header

$DSE << DSE_EOF

dump -bl=1 -count=2 -header

DSE_EOF

# try dumping record zero and another non existing record

$DSE << DSE_EOF

dump -record=0
dump -record=345

DSE_EOF

# record/offset qualifier with fileheader

$DSE << DSE_EOF

dump -file -rec=3 -bl=4
dump -file -off=9 -bl=4

DSE_EOF

# dumping number of consecutive records

$DSE << DSE_EOF

dump -header  -block=3 -rec=2 -count=2

DSE_EOF

# all the above with offset qualifier

$DSE << DSE_EOF

dump -offset=0
dump -offset=10 -head

dump -offset=25 -count=0
dump -header  -block=3 -off=10 -count=2


DSE_EOF

#try with -GLO option

# without opening an output file.
# The below 2 should error out with
#	"Error:  must open an output file before dump", though dumping with -glo is not supported in UTF-8 mode

$DSE << DSE_EOF

dump -block=3 -record=2 -glo
dump -block=3 -offset=20 -glo

DSE_EOF

# open an output file and test
# The below 3 dumps had -glo. Since the intent of this segment is to check if dump works when file is open and doesn't when the files isn't open, the dump format is changed to -zwr

$DSE << DSE_EOF >&! dse_glo.out

open -file=seq.dat
dump -block=3 -record=2 -glo
dump -block=3 -offset=20 -glo
dump -block=0 -offset=20 -glo
close

DSE_EOF

echo ""
set no_lines=0
set gtmchset=""
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) set gtmchset="UTF-8"
endif
if ("UTF-8" == $gtmchset) then
	set no_lines=`$grep "Error:  GLO format is not supported in UTF-8 mode" dse_glo.out | wc -l`
else
	set no_lines=`$grep -E "1 GLO records written.|DSE> %YDB-E-CANTBITMAP, Can't perform this operation on a bit map .block at a 200 hexadecimal boundary." dse_glo.out | wc -l`
	mv dse_glo.out dse_glo.outx
	$grep -v CANTBITMAP dse_glo.outx > dse_glo.out
endif

if ("3" == $no_lines) then
	echo "TEST-I-PASS. dse dump in glo format worked as expected"
else
	echo "TEST-E-DUMP, dse dump in glo format failed. Check the dump output in the file dse_glo.out"
endif

# check if close is proper

$DSE << DSE_EOF

dump -block=3 -offset=20 -glo

DSE_EOF

$GTM <<GTM_EOF
S ^NULLGBL=""
GTM_EOF

$DSE <<DSE_EOF
find -reg=DEFAULT
dump -bl=5
DSE_EOF

$DSE <<DSE_EOF >&! dse_NULLGBL.out
find -reg=DEFAULT
open -file="null.glo"
dump -bl=5 -glo
close
open -file="null.zwr"
dump -bl=5 -zwr
DSE_EOF

echo ""
$grep "ZWR records written" dse_NULLGBL.out
set dse_stat=0
set no_lines=0
if ("UTF-8" == $gtmchset) then
	set no_lines=`$grep "GLO format is not supported in UTF-8 mode" dse_NULLGBL.out | wc -l`
	if ("1" == $no_lines) set dse_stat=1
else
	set no_lines=`$grep "1 GLO records written." dse_NULLGBL.out| wc -l`
	if ("1" == $no_lines) set dse_stat=1
endif
if ($dse_stat) then
	echo "TEST-I-PASS. dse dump -bl=5 of glo and zwr worked as expected"
else
	echo "TEST-E-DUMP -bl=5 failed. Check the file dse_NULLGBL.out"
endif
# Verify if the above operations have done any damage to the database
$gtm_tst/com/dbcheck.csh
