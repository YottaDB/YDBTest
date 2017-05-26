#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo 'zro_search test starts.....'
#
$gtm_dist/mumps $gtm_tst/$tst/inref/*.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib1"$gt_ld_shl_suffix" decimal.o avg.o  ${gt_ld_m_shl_options} >& zro_search_ld.outx
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib2 main.o square.o ${gt_ld_m_shl_options} >>& zro_search_ld.outx
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib3"$gt_ld_shl_suffix" factor.o cube.o newavg.o ${gt_ld_m_shl_options} >>& zro_search_ld.outx
\rm decimal.o avg.o newavg.o main.o square.o factor.o cube.o
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
\rm  *sc.m
\cp *.m src
\cp *.o obj
#
#
##############################################
$GTM<<EOF1
S \$zro=""
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib_bad_txt"
S \$zro="./noexist$gt_ld_shl_suffix"
S \$zro="./shlib1$gt_ld_shl_suffix(./src) ./shlib"
S \$zro="./shlib2"
W "ZL avg",! ZL "avg"
S \$zro="./shlib2 ./obj(./src) /dev/tty"
S \$zro="./shlib2 ./obj(./src)"
W "ZL avg",! ZL "avg"
W "Do ^avg",! do ^avg
S \$zro="./shlib1$gt_ld_shl_suffix"
W "ZL avg",! ZL "avg"
h
EOF1
#
#remove object files generated from explicit ZLINKS
\rm *.o
#
##############################################
$GTM<<EOF2
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ./obj(./src)"
W "ZL main",! ZL "main"
W "Do ^main",! do ^main
ZL "\$gtm_tst/\$tst/inref/main.m":"-noobject"
W "W \$zsource",! W \$zsource
h
EOF2
#
#
##############################################
$GTM<<EOF3
S \$zro="./shlib1$gt_ld_shl_suffix"
W "Do ^avg",! do ^avg
h
EOF3
#
#
##############################################
$GTM<<EOF4
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix obj(./src)"
W "Do ^main",! do ^main
h
EOF4
#
#
##############################################
$GTM<<EOF5
S \$zro="./shlib2 ./obj(./src) ./shlib1$gt_ld_shl_suffix"
W "Do ^main",! do ^main
S \$zro=" ./obj(./src) ."
W "Do ^main",!  do ^main
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix obj(./src)"
W "Do main3",! Do ^main3
h
EOF5
#
##############################################
$GTM<<EOF6
S \$zro="./shlib1$gt_ld_shl_suffix ./obj(./src) ./shlib2 ./shlib3$gt_ld_shl_suffix"
W "Do ^main",! do ^main
W "Do ^avg",! do ^avg
h
EOF6
#
#
##############################################
$GTM<<EOF7
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./obj(./src) ./shlib3$gt_ld_shl_suffix"
W "Do ^main",! do ^main
W "Do ^avg",! do ^avg
h
EOF7
#
#
# Remove object files generated from explicit ZLINKS
# Move all .m files to src. Source paths must
# be searched for source files
\mv *.m src
#
##############################################
cat <<\xyz > mvim
#! /usr/local/bin/tcsh -f
vim -c {:q} \$* >& /dev/null
\xyz
chmod +x mvim
setenv EDITOR mvim
#
##############################################
$GTM<<EOF8
S \$zro="./shlib1$gt_ld_shl_suffix ./obj(./src) ."
W "Do ^avg",! Do ^avg
W "ZEDIT avg",! ZEDIT "avg"
W "W \$zsource",! W \$zsource
W "ZPRINT average^avg",! ZPRINT average^avg
W "ZL avg",! ZL "avg"
W "\$TEXT(average^avg)",! W \$TEXT(average^avg)
h
EOF8
#
#
##############################################
cp $gtm_tst/$tst/inref/avgsc.m avg.m
$gtm_dist/mumps -noembed_source avg.m	# want to generate TXTSRCMAT error, hence noembed_source
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib1"$gt_ld_shl_suffix" avg.o  ${gt_ld_m_shl_options} >& zro_search_ld.outx
$GTM<<EOF9
S \$zro=". ./shlib1$gt_ld_shl_suffix"
W "ZL avg",! ZL "avg"
ZSYSTEM "echo \""Hello world\"" > avg.m"
W "ZPRINT average^avg",! ZPRINT average^avg
W "\$TEXT(average^avg)",! W \$TEXT(average^avg)
h
EOF9
#
#
##############################################
#cat <<\xyz > mvim
##! /usr/local/bin/tcsh -f
#vim -c {:q} \$* >& /dev/null
#\xyz
#
#
$GTM<<EOF9
S \$zro="./shlib1$gt_ld_shl_suffix ./shlib2 ./shlib3$gt_ld_shl_suffix ./obj(./src) ."
W "ZEDIT main",! ZEDIT "main"
W "W \$zsource",! W \$zsource
W "ZEDIT main (full path)",! ZEDIT "\$gtm_tst/\$tst/inref/main.m"
W "W \$zsource",! W \$zsource
h
EOF9
#
echo 'End of zro_search tests.....'
