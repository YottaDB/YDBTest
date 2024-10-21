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

echo '##########################################################################'
echo '########## Test various code issues identified by fuzz testing ###########'
echo '##########################################################################'

echo ""
echo "---- prepare ----"
setenv ydb_msgprefix 'GTM'

set separator="--------------------------------------------------------------------------"

echo "# create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "# compile errors"
$gtm_dist/mumps -run ydb1044

set case_list = `cat $gtm_tst/r202/inref/ydb1044.m | grep TEST_CASE | cut -f1`
foreach case ( $case_list )

        # sed: count lines from "^${case}" label to line closing "quit$", then sub 2
        set line_count = `sed -n "/^${case}/,/quit"\$"/p" $gtm_tst/r202/inref/ydb1044.m | wc -l`
        @ line_count -= 2
        set case_desc = `cat $gtm_tst/r202/inref/ydb1044.m | grep ^${case} | cut -d: -f2`

        echo ""
        if ($case == "argc1") then
                echo $separator
                echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1044#note_2164370404'
                echo '# Prior to GT.M V7.0-004, this test failed with an assert/SIG-11'
                echo '# Expecting only MAXARGCNT errors in below output in each invocation'
                echo $separator
        endif
        if ($case == "mlab") then
                echo $separator
                echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1044#note_2164048856'
                echo '# Prior to GT.M V7.0-004 / YottaDB r2.02, this test failed with an assert'
                echo '# in debug build'
                echo '# Expecting only LABELMISSING errors in below output in each invocation'
                echo $separator
        endif
        if ($case == "pc1") then
                echo $separator
                echo '# Test of https://gitlab.com/YottaDB/DB/YDB/-/issues/1044#note_2163866307'
                echo '# Prior to GT.M V7.0-004 / YottaDB r2.02, this test failed with SIG-11 in'
                echo '# both release and debug builds'
                echo '# Expecting INVSVN/EQUAL/SPOREOL errors in below output in each invocation'
                echo $separator
        endif

        echo '# checking case "'$case'" ('${case_desc}'), with program'
        # run program and filter empty/prompt-only lines
        $gtm_dist/mumps \
                -run ${case}^ydb1044 \
                | grep -Ev '^$|^GTM>$|^YDB>$'

        echo ''

        echo '# checking case "'$case'", ('${case_desc}') direct'
        # parse commands from the program itself, then
        # feed into the M CLI, and filter empty/prompt-only lines
        cat \
                $gtm_tst/r202/inref/ydb1044.m \
                | grep ^${case} -A${line_count} \
                | tail -n${line_count} \
                \
                | $gtm_dist/mumps -dir \
                | grep -Ev '^$|^GTM>$|^YDB>$'

end

echo "---- cleanup ----"
echo "shutdown database"
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
