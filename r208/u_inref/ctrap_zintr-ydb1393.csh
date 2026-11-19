#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#---------------------------------------------------------------------------------------------------------------------#"
echo '# [YDB#1393] Test a CTRAP character typed while a $ZINTERRUPT handler runs gives a CTRAP error in the handler         #'
echo '# A process sets a CTRAP character on its principal device and a $ZINTERRUPT, and an expect script sends it a MUPIP   #'
echo '# INTRPT and types the CTRAP character while the $ZINTERRUPT handler runs. The handler has an $ETRAP that reports     #'
echo '# the error. The subtest checks that the handler gets a CTRAP error, and that the process then ends normally.         #'
echo '#   1. <CTRL-C> typed while the handler runs a loop with no READ, which YDB#1393 lost in a Release build              #'
echo '#   2. <CTRL-A> typed during a READ in the handler                                                                    #'
echo '#   3. <CTRL-C> typed during a READ in the handler                                                                    #'
echo '#   4. case 3 with a line typed right after the <CTRL-C>                                                              #'
echo '#   5. with no $ZINTERRUPT, each of <CTRL-A>, <CTRL-B>, <CTRL-D> and <CTRL-C> typed during a READ that has it as the  #'
echo '#      CTRAP character, then a FOR loop that checks that no event is recognized later                                 #'
echo '# Before the fix, a Debug build fails an assert in every case.                                                        #'
echo "#---------------------------------------------------------------------------------------------------------------------#"
echo

cp $gtm_tst/$tst/inref/ydb1393.m .
(expect -d $gtm_tst/$tst/u_inref/ctrap_zintr-ydb1393.exp > ctrap_zintr.exp.out) >& ctrap_zintr.exp.dbg
cat ctrap_zintr.exp.out
