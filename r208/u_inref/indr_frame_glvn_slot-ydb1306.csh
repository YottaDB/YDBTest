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

echo "#-------------------------------------------------------------------------------------------------#"
echo "# [YDB#1306] glvn pool slots used inside XECUTE and other indirect frames are freed when the frame #"
echo "# ends, and do not replace the slot of a FOR in the frame they run in                              #"
echo "#-------------------------------------------------------------------------------------------------#"
echo
echo '# SET @ref=..., $ORDER(@ref,-1) and a FOR over a subscripted or indirect control variable save the'
echo '# variable in a slot of the glvn pool. A slot is freed when the frame that took it ends, but an indirect'
echo '# frame (XECUTE, $ETRAP, $ZTRAP, a ZBREAK action, the $ZTIMEOUT vector, $ZINTERRUPT) started with the'
echo '# glvn pool state of the frame it runs in, and never freed its slots. So:'
echo '# - stages 1 and 2 : an error inside XECUTE while SET or $ORDER saved an indirect reference left its'
echo '#   slot allocated, so a process that repeated it grew without limit'
echo '# - stage 3 : the same for a FOR over a subscripted control variable in any of those indirect frames,'
echo '#   even without an error'
echo '# - stage 4 : such a FOR in an indirect frame took over the slot of a FOR at the same nesting level in'
echo '#   the frame it runs in, so the outer FOR stepped the inner control variable and never ended'
echo '#'
echo '# Stages 1 to 3 compare $ZREALSTOR after 1/10 of the runs and at the end. Before the fix, every leak'
echo '# made it grow by several hundred bytes per run, and a Debug build failed an assert in glvn_pool.c.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1306.m .

echo '# Stage 1 : an error inside XECUTE while $ORDER(@ref,-1) saves its indirect reference, 100000 times'
echo '#   xecute "set z=$order(@ref,-1)" with ref="x(undefv)" and undefv undefined, in a function with $ETRAP'
echo '# Command : $gtm_dist/mumps -run errxord^ydb1306'
echo '# Before the fix, a Release build grew $ZREALSTOR by about 44MB, so the line below was a WRONG line,'
echo '# and a Debug build failed an assert in glvn_pool.c, so the line below was missing'
$gtm_dist/mumps -run errxord^ydb1306
echo

echo '# Stage 2 : an error inside XECUTE while SET @ref=... saves its indirect reference, 100000 times'
echo '#   xecute "set @ref=1" with ref="x(undefv)" and undefv undefined, in a function with $ETRAP'
echo '# Command : $gtm_dist/mumps -run errxset^ydb1306'
echo '# Before the fix, the same results as in stage 1'
$gtm_dist/mumps -run errxset^ydb1306
echo

echo '# Stage 3 : a FOR over a subscripted control variable in each kind of indirect frame, without errors'
echo '#   for b(1)=1:1:2 set cnt=cnt+1'
echo '#   run 100000 times as XECUTE, $ETRAP, $ZTRAP and ZBREAK action code, and 5000 times as the $ZTIMEOUT'
echo '#   vector and as $ZINTERRUPT (sent to the process itself by $ZSIGPROC)'
echo '# Before the fix, a Release build grew $ZREALSTOR by about 51MB for 100000 runs and 3MB for 5000, so'
echo '# each line below was a WRONG line, and a Debug build failed an assert in glvn_pool.c, so each line'
echo '# below was missing'
foreach label (forxec foretrap forztrap forzbrk forztout forzint)
	echo "# Command : "'$gtm_dist/mumps -run '"${label}^ydb1306"
	$gtm_dist/mumps -run ${label}^ydb1306
end
echo

echo '# Stage 4 : a FOR over a(1) whose body has a FOR over b(1) in an indirect frame (YDB#1318)'
echo '#   for a(1)=1:1:3 quit:cnt>20  xecute "for b(1)=1:1:2 set cnt=cnt+1"'
echo '#   also with indirect control variables, and with the inner FOR in the $ZTIMEOUT vector and in'
echo '#   $ZINTERRUPT, which interrupt the outer FOR'
echo '#   expect the inner FOR to run 6 times in all and the outer FOR to end with a(1)=3'
echo '# Before the fix, the outer FOR stepped b(1), which the inner FOR reset each time, so it never ended'
echo '# until "quit:cnt>20", and each line below was a WRONG line with the inner FOR run 22 times and a(1)=1'
foreach label (nestxec nestind nestztout nestzint)
	echo "# Command : "'$gtm_dist/mumps -run '"${label}^ydb1306"
	$gtm_dist/mumps -run ${label}^ydb1306
end
echo

echo "# Done"
