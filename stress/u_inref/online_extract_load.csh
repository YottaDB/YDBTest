#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
\touch NOT_DONE.EXTRACT
# Wait for sufficient globals to be set before proceeding to extract-load
# job 6-10 are the ones that does TCOMMIT. Jobs 2-5 does TROLLBACK. So wait for job 6 to have executed 5 iterations
$GTM << aaa
for  h 1  q:\$GET(^lasti(6,^instance))>5
aaa
@ cnt = 1
while ($cnt <= 10)
	echo "cnt : $cnt"
	date
	if ($cnt > 5) then
		# Do not extract all variables because loading older values can cause some logical problem.
		# go format is not supported in UTF-8 mode.
		#if ($cnt == 6) $MUPIP extract -format=go -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo
		#if ($cnt == 7) $MUPIP extract -format=bin -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo # S9G06-002615
		#if ($cnt == 7) $MUPIP extract -format=go  -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo
		if ($cnt == 8) $MUPIP extract -format=zwr -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo
		if ($cnt == 9) $MUPIP extract -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo
		if ($cnt == 10) $MUPIP extract -select="^afill,^e,^cfill,^dfill,^efill,^ffill,^%1,^b*" extr_${cnt}.glo
	else
		$MUPIP extract extr_${cnt}.glo
	endif
	if ($status) then
		echo "Extract TEST FAILED"
		break
	endif
        if ($1 == "PRI" && $cnt > 5 ) then
		#if ($cnt == 6) $MUPIP load -format=go extr_${cnt}.glo
		##if ($cnt == 7) $MUPIP load -format=bin extr_${cnt}.glo  : See S9G06-002615
		#if ($cnt == 7) $MUPIP load -format=go extr_${cnt}.glo
		if ($cnt == 8) $MUPIP load -format=zwr extr_${cnt}.glo
		if ($cnt == 9) $MUPIP load extr_${cnt}.glo
		if ($cnt == 10) $MUPIP load extr_${cnt}.glo
	endif
        @ cnt = $cnt + 1
end
# There was a previous comment here warning not to run INTEG at the same time when dbcheck is been run below. It has been
# observed after lots of stress test runs with ONLINE INTEG running parallely that no issues exist in running more than
# one INTEG at the same time. 10/2009 - S7KK
# However, OLI and MUPIP REORG UPGRADE/DOWNGRADE cannot coexist. Hence one of those is picked randomly in concurr.csh and
# concurr_small.csh. But if UPGRADE/DOWNGRADE is chosen randomly, then we cannot do a OLI below (done as a part of
# dbcheck_base_filter.csh). Although, we can check if OLI was chosen randomly and pass -online and -noonline accordingly,
# it's okay to pass -noonline unconditionally since we would anyways be exercising -online due to randomness in concurr and
# concurr_small. Note -nosprgde should be first parameter in case multiple parameters are specified.
$gtm_tst/com/dbcheck_base_filter.csh -nosprgde -noonline -noskipregerr
#
########################
\rm -f NOT_DONE.EXTRACT
