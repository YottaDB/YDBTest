#!/usr/local/bin/tcsh -f
echo "Compile Routines"
$gtm_exe/mumps $gtm_tst/$tst/inref/sstpdrv.m
$gtm_exe/mumps $gtm_tst/$tst/inref/zstpmain.m
echo "Create Shared Library"
$gt_ld_m_shl_linker ${gt_ld_option_output} sh_zsteps$gt_ld_shl_suffix sstpdrv.o zstpmain.o ${gt_ld_m_shl_options} >& shlib_zstep_long_ld.outx
echo "Shared Library Creation done"
#
#
\rm -f *.o					# Remove object files to make sure they do not get used or interfere
#
$GTM << aaa
S \$zro="./sh_zsteps$gt_ld_shl_suffix ."
do creafn^sstpdrv
halt
aaa
chmod 755 zsteps.csh
./zsteps.csh
