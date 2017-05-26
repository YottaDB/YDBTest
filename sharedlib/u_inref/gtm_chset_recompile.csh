$echoline
cat << EOF
# Test that GT.M errors if the gtm_chset setting is different at run-time
from the setting at compile-time.
EOF

$echoline
echo "M to UTF-8"
mkdir m_to_utf8
cd m_to_utf8
$switch_chset "M"
$gtm_exe/mumps $gtm_tst/com/utfpattern.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix utfpattern.o ${gt_ld_m_shl_options}  >& gtm_chset_recompile_ld.outx
rm *.o
setenv gtmroutines "./shlib$gt_ld_shl_suffix ."
$gtm_exe/mumps -run utfpattern >& out1m.out
$gtm_tst/com/wait_for_log.csh -log out1m.out -duration 0 -grep -message "M in effect"

$switch_chset "UTF-8"

setenv gtmroutines "./shlib$gt_ld_shl_suffix ."
$gtm_exe/mumps -run utfpattern >& out1utf8.out
$gtm_tst/com/check_error_exist.csh out1utf8.out DLLCHSETM
cat out1utf8.out

cd ..
######################################################################
$echoline
echo "UTF-8 to M"
mkdir utf8_to_m
cd utf8_to_m
$switch_chset "UTF-8"
$gtm_exe/mumps $gtm_tst/com/utfpattern.m
$gt_ld_m_shl_linker ${gt_ld_option_output} shlib$gt_ld_shl_suffix utfpattern.o ${gt_ld_m_shl_options}  >>& gtm_chset_recompile_ld_outx
rm *.o
setenv gtmroutines "./shlib$gt_ld_shl_suffix ."

$gtm_exe/mumps -run utfpattern >& out2utf8.out
$gtm_tst/com/wait_for_log.csh -log out2utf8.out -duration 0 -grep -message "UTF-8 in effect"

$switch_chset "M"
setenv gtmroutines "./shlib$gt_ld_shl_suffix ."

$gtm_exe/mumps -run utfpattern >& out2m.out
$gtm_tst/com/check_error_exist.csh out2m.out DLLCHSETUTF8
cat out2m.out
$echoline
