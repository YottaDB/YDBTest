#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1
setenv save_gtmroutines "$gtmroutines"
#
##################################################
###  incr_link.csh                             ###
###  Tests for incremental linking of shared   ###
###  objects                                   ###
##################################################
#
#
echo 'Incr_link tests starts....'
#
source $gtm_tst/com/portno_acquire.csh >> portno.out
#
#
######## verify linking recompiled, smaller sources works
#
cp $gtm_tst/$tst/inref/bigavg.m avg.m
cp $gtm_tst/$tst/inref/bigcube.m cube.m
cp $gtm_tst/$tst/inref/bigfactor.m factor.m
$gtm_dist/mumps *.m
cp $gtm_tst/$tst/inref/avg.m avg.m
cp $gtm_tst/$tst/inref/cube.m cube.m
cp $gtm_tst/$tst/inref/factor.m factor.m
# The recompile is only done if the modification time of the object file is older than
# that of the M code.  The resolution of the modification time (time_t) is in seconds,
# so we have to wait at least one second before setting the time for the m code.  Otherwise,
# the recompile might not happen.
sleep 1
touch avg.m cube.m factor.m
$gtm_dist/mumps *.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix avg.o cube.o factor.o ${gt_ld_m_shl_options} >& incr_link_ld.outx
\rm avg.* cube.* factor.* shlib$gt_ld_shl_suffix
#
#
##############################################
#
cp $gtm_tst/$tst/inref/jobmain.m .
$gtm_dist/mumps $gtm_tst/$tst/inref/*.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib1$gt_ld_shl_suffix decimal.o avg.o ${gt_ld_m_shl_options} >>& incr_link_ld.outx
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib2 main.o jobmain.o square.o ${gt_ld_m_shl_options} >>& incr_link_ld.outx
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib3$gt_ld_shl_suffix factor.o cube.o newavg.o ${gt_ld_m_shl_options} >>& incr_link_ld.outx
#
\rm decimal.o avg.o newavg.o main.o square.o factor.o cube.o jobmain.o
#
\cp $gtm_tst/$tst/inref/*sc.m .
set prv = `ls *sc.m`
set ff = `ls *sc.m |sed 's/sc//g'`
@ cnt = 1
    while ($cnt <= $#prv)
	\mv $prv[$cnt] $ff[$cnt]
	@ cnt++
    end
#
$gtm_dist/mumps *.m
mkdir src
mkdir obj
\rm *sc.m
\mv *.m src
\mv *.o obj
\cp src/jobmain.m .
#
#
##############################################
#
$GTM<<EOF1
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ./obj(./src)"
W "Do ^main",! do ^main
W "Do ^avg",! do ^avg
h
EOF1
#
#
#
#
##############################################
$GTM<<EOF2
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix . ./obj(./src)"
W "Do ^avg",! do ^avg
S \$zro=\$P(\$zro," ",5)_" "_\$P(\$zro," ",1,4)
W "ZL avg",! ZL "avg"
W "Do ^avg",! do ^avg
h
EOF2
#
#
##############################################
$GTM<<EOF3
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix "_\$ztrnlnm("tst_working_dir")_"/obj"_"("_\$ztrnlnm("tst_working_dir")_"/src)"
W "Do ^main",! do ^main
S \$zro=\$P(\$zro," ",1,2)_" "_\$P(\$zro," ",4)_" "_\$P(\$zro," ",3)
W "ZL factor",! ZL "factor"
W "Do ^main",! do ^main
h
EOF3
#
#
#
##############################################
$GTM<<EOF4
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ./obj(src) ."
W "Do ^main",! d ^main
W "Do ^avg",! d ^avg
W "\$VIEW(RTNNEXT,main)",! W \$VIEW("RTNNEXT","main")
W "\$VIEW(RTNNEXT,base)",! W \$VIEW("RTNNEXT","base")
W "\$VIEW(RTNNEXT,avg)",! W \$VIEW("RTNNEXT","avg")
h
EOF4
#
#
##############################################
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 1
$GTM <<zzz
f i=1:1:10 s ^X(i)=i
h
zzz
#
##############################################
setenv gtmroutines "./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ./obj(./src) ."
echo "mumps -r main"
$gtm_dist/mumps -r main
##############################################
$GTM<<EOF5
S \$zro="./obj(src) ./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ."
W "ZL factor",! ZL "factor"
W "Do ^jobmain",! Do ^jobmain
W "Job ^jobmain",! job ^jobmain
EOF5
#
$gtm_tst/com/wait_for_log.csh -log  jobmain.mjo -waitcreation -duration 60 -message "Job main done"
echo "main.mjo....."
cat *.mjo*
#
# Remove port reservation file
$gtm_tst/com/portno_release.csh
#
#
######## Test writing to literal table ########
$GTM<<EOF7
Write "Do ^literwrt",! Do ^literwrt
h
EOF7
#
###############################################
#                                             #
# Compare time to load and execute 1000 disk  #
# routines vs 1000 shared routines            #
#                                             #
###############################################
#
@ total_files = 1000
@ cnt = 1
    while ($cnt < $total_files)
	@ temp_cnt=$cnt + 1
	echo ' '\;w \"I am in a$cnt.m\",\! > a"$cnt".m
	echo " d ^a$temp_cnt" >> a"$cnt".m
	echo " q" >> a"$cnt".m
	@ cnt++
    end
#
echo ' 'w \"I am in a$total_files.m\",\! > a"$total_files".m
echo "  d ^b" >> a"$total_files".m
echo "  q" >> a"$total_files".m
#
echo ' 'w \"I am in b.m\",\! > b.m
echo "  q" >> b.m
#
set diskbefore = `date +%s`
$GTM <<EOF
d ^a1
h
EOF
#
set diskafter = `date +%s`
@ disk_time = $diskafter - $diskbefore
echo "$disk_time" > disk.txt
#
#
echo "Create a shared library with files"
$gt_ld_m_shl_linker ${gt_ld_option_output} shbin$gt_ld_shl_suffix a*.o ${gt_ld_m_shl_options} >>& incr_link_ld.outx
set sharedbefore = `date +%s`
$GTM <<EOF1
s \$zro="./shbin$gt_ld_shl_suffix .",\$zt="zm 150376532" ;force a GTMASSERT if do ^a1 below fails for some reason.
w \$zro
d ^a1
h
EOF1
#

set sharedafter = `date +%s`
@ shared_time = $sharedafter - $sharedbefore
echo "$shared_time" > shared.txt

# Allow for a 2 sec time difference between shared lib compiling time and disk routine compiling time (rev 1.10)
@ disktimeplus2 = $disk_time + 2

# Time comparison is not done as of now as it needs significant rework
# Check <incr_link_disk_faster_than_shared_library/resolution_v2.txt> for the complete discussion
#if ( $shared_time > $disktimeplus2 ) then
#	echo "ERROR: Shared routines took more time than disk routines!"
#	echo "Check disk.txt & shared.txt"
#else
#	echo "PASS: Shared routines executed in less time than disk routines."
#endif
#
#
echo 'End of Incr_link tests...'
setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
