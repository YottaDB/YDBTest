#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# [YDB#1102] Test enhancements to yottadb CLI options'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

echo '# Create a simple [ydb1102.m] routine to run with various options'
echo 'ydb1102 write "PASS",!' >&! ydb1102.m
echo

echo '### Test 1: help options'
echo '# Test --help option [$ydb_dist/yottadb --help]:'
$ydb_dist/yottadb --help
echo
echo '# Test -h option [$ydb_dist/yottadb -h]:'
$ydb_dist/yottadb -h
echo

echo "### Test 2: correct error output for invalid options prefixed with 'no'"
echo '# Test --nooption invalid option [$ydb_dist/yottadb --nooption]:'
$ydb_dist/yottadb --nooption
echo '# Test --nothing invalid option [$ydb_dist/yottadb --nothing]:'
$ydb_dist/yottadb --nothing
echo '# Test valid negatable option --nowarnings still works [$ydb_dist/yottadb --nowarnings -run ydb1102]:'
$ydb_dist/yottadb --nowarnings -run ydb1102
rm ydb1102.o
echo

echo "### Test 3: '--' syntax for existing options"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test --debug option [$ydb_dist/yottadb --debug -run ydb1102]:'
$ydb_dist/yottadb --debug -run ydb1102
rm ydb1102.o
echo '# Test --direct_mode option [echo '"'write "'"PASS",!'"'"' | $ydb_dist/yottadb --direct]:'
echo 'write "PASS",!' | $ydb_dist/yottadb --direct
echo '# Test --dynamic_literals option [$ydb_dist/yottadb --dynamic_literals -run ydb1102]:'
$ydb_dist/yottadb --dynamic_literals -run ydb1102
rm ydb1102.o
echo '# Test --embed_source option [$ydb_dist/yottadb --embed_source -run ydb1102]:'
$ydb_dist/yottadb --embed_source -run ydb1102
rm ydb1102.o
echo '# Test --ignore option [$ydb_dist/yottadb --ignore -run ydb1102]:'
$ydb_dist/yottadb --ignore -run ydb1102
rm ydb1102.o
echo '# Test --inline_literals option [$ydb_dist/yottadb --inline_literals -run ydb1102]:'
$ydb_dist/yottadb --inline_literals -run ydb1102
rm ydb1102.o
echo '# Test --labels option [$ydb_dist/yottadb --labels=UPPER -run ydb1102]:'
$ydb_dist/yottadb --labels=UPPER -run ydb1102
rm ydb1102.o
echo '# Test --length option [$ydb_dist/yottadb --length=32 -run ydb1102]:'
$ydb_dist/yottadb --length=32 -run ydb1102
rm ydb1102.o
echo '# Test --line_entry option [$ydb_dist/yottadb --line_entry -run ydb1102]:'
$ydb_dist/yottadb --line_entry -run ydb1102
rm ydb1102.o
echo '# Test --list option [$ydb_dist/yottadb --list="ydb1102a.lis" -run ydb1102]:'
$ydb_dist/yottadb --list="ydb1102a.lis" -run ydb1102
file ydb1102a.lis
rm ydb1102.o
echo '# Test --machine_code option [$ydb_dist/yottadb --machine_code -run ydb1102]:'
$ydb_dist/yottadb --machine_code -run ydb1102
rm ydb1102.o
echo '# Test --nameofrtn option, confirm specified object file [ydb1102a1.o] created [$ydb_dist/yottadb --nameofrtn="ydb1102a1.o" ydb1102.m]:'
$ydb_dist/yottadb --nameofrtn="ydb1102a1.o" ydb1102.m
file ydb1102a1.o
echo '# Test --object option, confirm specified object file [ydb1102b1.o] created [$ydb_dist/yottadb --object="ydb1102b1.o" ydb1102.m]:'
$ydb_dist/yottadb --object="ydb1102b1.o" ydb1102.m
file ydb1102b1.o
echo '# Test --run option [$ydb_dist/yottadb --run ydb1102]:'
$ydb_dist/yottadb --run ydb1102
rm ydb1102.o
echo '# Test --space option [$ydb_dist/yottadb --list="ydb1102b.lis" --space=10 -run ydb1102]:'
$ydb_dist/yottadb --list="ydb1102b.lis" --space=10 -run ydb1102
rm ydb1102.o
echo '# Test --version option [$ydb_dist/yottadb --version]:'
$ydb_dist/yottadb --version
echo '# Test --warnings option [$ydb_dist/yottadb --warnings --run ydb1102]:'
$ydb_dist/yottadb --warnings --run ydb1102
rm ydb1102.o
echo

echo "### Test 4: Abbreviated '-' syntax for existing options"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test -dy option [$ydb_dist/yottadb -dy -run ydb1102]:'
$ydb_dist/yottadb -dy -run ydb1102
rm ydb1102.o
echo '# Test -e option [$ydb_dist/yottadb -e -run ydb1102]:'
$ydb_dist/yottadb -e -run ydb1102
rm ydb1102.o
echo '# Test -ig option [$ydb_dist/yottadb -ig -run ydb1102]:'
$ydb_dist/yottadb -ig -run ydb1102
rm ydb1102.o
echo '# Test -in option [$ydb_dist/yottadb -in -run ydb1102]:'
$ydb_dist/yottadb -in -run ydb1102
rm ydb1102.o
echo '# Test -la option [$ydb_dist/yottadb -la=UPPER -run ydb1102]:'
$ydb_dist/yottadb -la=UPPER -run ydb1102
rm ydb1102.o
echo '# Test -le option [$ydb_dist/yottadb -le=32 -run ydb1102]:'
$ydb_dist/yottadb -le=32 -run ydb1102
rm ydb1102.o
echo '# Test -lin option [$ydb_dist/yottadb -lin -run ydb1102]:'
$ydb_dist/yottadb -lin -run ydb1102
rm ydb1102.o
echo '# Test -lis option [$ydb_dist/yottadb -lis="ydb1102a.lis" -run ydb1102]:'
$ydb_dist/yottadb -lis="ydb1102a.lis" -run ydb1102
file ydb1102a.lis
rm ydb1102.o
echo '# Test -m option [$ydb_dist/yottadb -m -run ydb1102]:'
$ydb_dist/yottadb -m -run ydb1102
rm ydb1102.o
echo '# Test -n option, confirm specified object file [ydb1102a2.o] created [$ydb_dist/yottadb -n="ydb1102a2.o" ydb1102.m]:'
$ydb_dist/yottadb -n="ydb1102a2.o" ydb1102.m
file ydb1102a2.o
echo '# Test -o option, confirm specified object file [ydb1102b2.o] created [$ydb_dist/yottadb -o="ydb1102b2.o" ydb1102.m]:'
$ydb_dist/yottadb -o="ydb1102b2.o" ydb1102.m
file ydb1102b2.o
echo '# Test -r option [$ydb_dist/yottadb -r ydb1102]:'
$ydb_dist/yottadb -r ydb1102
rm ydb1102.o
echo '# Test -s option [$ydb_dist/yottadb --list="ydb1102b.lis" -s=10 -run ydb1102]:'
$ydb_dist/yottadb --list="ydb1102b.lis" -s=10 -run ydb1102
rm ydb1102.o
echo '# Test -v option [$ydb_dist/yottadb -v]:'
$ydb_dist/yottadb -v
echo '# Test -w option [$ydb_dist/yottadb -w --run ydb1102]:'
$ydb_dist/yottadb -w --run ydb1102
rm ydb1102.o
echo

echo "### Test 5: '--no' syntax for existing options"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test --nodynamic_literals option [$ydb_dist/yottadb --nodynamic_literals -run ydb1102]:'
$ydb_dist/yottadb --nodynamic_literals -run ydb1102
rm ydb1102.o
echo '# Test --noembed_source option [$ydb_dist/yottadb --noembed_source -run ydb1102]:'
$ydb_dist/yottadb --noembed_source -run ydb1102
rm ydb1102.o
echo '# Test --noignore option [$ydb_dist/yottadb --noignore -run ydb1102]:'
$ydb_dist/yottadb --noignore -run ydb1102
rm ydb1102.o
echo '# Test --noinline_literals option [$ydb_dist/yottadb --noinline_literals -run ydb1102]:'
$ydb_dist/yottadb --noinline_literals -run ydb1102
rm ydb1102.o
echo '# Test --noline_entry option [$ydb_dist/yottadb --noline_entry -run ydb1102]:'
$ydb_dist/yottadb --noline_entry -run ydb1102
rm ydb1102.o
echo '# Test --nolist option [$ydb_dist/yottadb --nolist -run ydb1102]:'
$ydb_dist/yottadb --nolist -run ydb1102
rm ydb1102.o
echo '# Test --noobject option, confirm no object file created [$ydb_dist/yottadb --noobject ydb1102.m]:'
$ydb_dist/yottadb --noobject ydb1102.m
file ydb1102.o
echo '# Test --nowarnings option [$ydb_dist/yottadb --nowarnings --run ydb1102]:'
$ydb_dist/yottadb --nowarnings --run ydb1102
rm ydb1102.o
echo

echo "### Test 6: '-no' syntax for existing options"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test -nody option [$ydb_dist/yottadb -nody -run ydb1102]:'
$ydb_dist/yottadb -nody -run ydb1102
rm ydb1102.o
echo '# Test -noe option [$ydb_dist/yottadb -noe -run ydb1102]:'
$ydb_dist/yottadb -noe -run ydb1102
rm ydb1102.o
echo '# Test -noig option [$ydb_dist/yottadb -noig -run ydb1102]:'
$ydb_dist/yottadb -noig -run ydb1102
rm ydb1102.o
echo '# Test -noin option [$ydb_dist/yottadb -noin -run ydb1102]:'
$ydb_dist/yottadb -noin -run ydb1102
rm ydb1102.o
echo '# Test -nolin option [$ydb_dist/yottadb -nolin -run ydb1102]:'
$ydb_dist/yottadb -nolin -run ydb1102
rm ydb1102.o
echo '# Test -nolis option [$ydb_dist/yottadb -nolis -run ydb1102]:'
$ydb_dist/yottadb -nolis -run ydb1102
rm ydb1102.o
echo '# Test -noo option, confirm no object file created [$ydb_dist/yottadb -noo ydb1102.m]:'
$ydb_dist/yottadb -noo ydb1102.m
file ydb1102.o
echo '# Test -now option [$ydb_dist/yottadb -now --run ydb1102]:'
$ydb_dist/yottadb -now --run ydb1102
rm ydb1102.o

echo "### Test 7: '--' syntax for MUPIP"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
$ydb_dist/yottadb --run GDE exit
echo '# Test [$ydb_dist/mupip create --region=DEFAULT]:'
$ydb_dist/mupip create --region=DEFAULT
echo '# Test [$ydb_dist/mupip set --key_size=956 --region=DEFAULT]:'
$ydb_dist/mupip set --key_size=956 --region=DEFAULT
echo '# Test [$ydb_dist/mupip reorg --upgrade --region=DEFAULT]:'
echo "y" | $ydb_dist/mupip reorg --upgrade --region=DEFAULT
echo '# Test [$ydb_dist/mupip integ --block=0 --brief]:'
$ydb_dist/mupip integ --block=0 --brief --file mumps.dat
echo

echo "### Test 8: '--' syntax for DSE"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test [$ydb_dist/dse change --fileheader --blk_size=1024]:'
$ydb_dist/dse change --fileheader --blk_size=1024
echo '# Test [$ydb_dist/dse add --block=0 --data="new data" --key="^x" --record=1]:'
$ydb_dist/dse add --block=0 --data="new data" --key="^x" --record=1
echo '# Test [$ydb_dist/dse all --buffer_flush]:'
$ydb_dist/dse all --buffer_flush
echo '# Test [$ydb_dist/dse dump --block=0 --header]:'
$ydb_dist/dse dump --block=0 --header
echo

echo "### Test 9: '--' syntax for LKE"
echo '## It is enough for the following commands to not fail to test the YDB#1102 changes,'
echo '## since these are CLI parser-only changes and it is not straightforward to validate the'
echo '## behavior of each option.'
echo '# Test [$ydb_dist/lke show --region=DEFAULT]:'
$ydb_dist/lke show --region=DEFAULT
echo '# Test [$ydb_dist/lke clnup --integ]:'
$ydb_dist/lke clnup --integ
echo '# Test [$ydb_dist/lke clear --all]:'
$ydb_dist/lke clear --all
echo

echo "### Test 10: MUMPS '--run' syntax behaves the same as '-run' in various edge cases"
echo ' zwrite $zcmdline' >& cmd.m
echo '# Test [$ydb_dist/yottadb -run cmd]:'
$ydb_dist/yottadb -run cmd
echo '# Test [$ydb_dist/yottadb --run cmd]:'
$ydb_dist/yottadb --run cmd
echo '# Test [$ydb_dist/yottadb - run cmd]:'
$ydb_dist/yottadb - run cmd
echo '# Test [$ydb_dist/yottadb -- run cmd]:'
$ydb_dist/yottadb -- run cmd
echo '# Test [$ydb_dist/yottadb - run cmd abc]:'
$ydb_dist/yottadb - run cmd abc
echo '# Test [$ydb_dist/yottadb -- run cmd abc]:'
$ydb_dist/yottadb -- run cmd abc
echo '# Test [$ydb_dist/yottadb - - run cmd abc]:'
$ydb_dist/yottadb - - run cmd abc
echo '# Test [$ydb_dist/yottadb -  - run cmd abc]:'
$ydb_dist/yottadb -  - run cmd abc
echo '# Test [$ydb_dist/yottadb - -run cmd abc]:'
$ydb_dist/yottadb - -run cmd abc
echo '# Test [$ydb_dist/yottadb -  -run cmd abc]:'
$ydb_dist/yottadb -  -run cmd abc
echo '# Test [$ydb_dist/yottadb -   -run cmd abc]:'
$ydb_dist/yottadb -   -run cmd abc
