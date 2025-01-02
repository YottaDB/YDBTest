#!/usr/local/bin/tcsh
#################################################################
#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
#################################################################
#
# Implement second half of gtm7952. Tests call out EXTCALLBOUNDS/EXCEEDSPREALLOC when exceeding preallocation of gtm_string_t/gtm_char_t
#
echo '# GT.M protects buffers used for external calls and produces an EXTCALLBOUNDS error if the external call attempts to exceed the space requested by the call table definition'
echo '# Previously GT.M did not provide this protection and used a less efficient strategy for managing the space'
echo '# Additionally, when an external call exceeds its specified preallocation (gtm_string_t * or gtm_char_t * output), GT.M produces an EXCEEDSPREALLOC error'
echo '# Previously GT.M did not immediately detect this condition, which could cause subsequent hard to diagnose failures.'
echo '# GT.M supports call-specific options in external call tables by appending a colon to the end of the line followed by zero or more space separated, case-insensitive keywords'
echo '# The SIGSAFE keyword attests that the specific call does not create its own signal handlers, which allows GT.M to avoid burdensome signal handler coordination for the external call'
echo '# Previously, and by default, GT.M saves and restores signal setups for external calls.'

# The callout table needs the sigsafe modifier so that M handles the buffer overflow rather than C (which just produces a segmentaion fault)
cat >> callOut.xc << xx
`pwd`/gtm7952b.so
callOutStr: int callOutStr(O:gtm_string_t *[1]) : sigsafe
callOutStr2: int callOutStr2(O:gtm_string_t *[1]) : sigsafe
callOutChar: int callOutChar(O:gtm_char_t **) : sigsafe
callOutChar2: int callOutChar2(O:gtm_char_t **) : sigsafe
xx
setenv GTMXC `pwd`/callOut.xc
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtm7952b.c
$gt_ld_shl_linker ${gt_ld_option_output}gtm7952b${gt_ld_shl_suffix} $gt_ld_shl_options gtm7952b.o $gt_ld_syslibs

echo
echo '# Testing EXCEEDSPREALLOC error from gtm_string_t* by setting length > allocated'
$gtm_dist/mumps -run %XCMD 'do &callOutStr(.x) write x,!'
echo '# Testing EXTCALLBOUNDS error from gtm_string_t* by writing out of buffer range'
echo '# this produces an expected core file'
$gtm_dist/mumps -run %XCMD 'do &callOutStr2(.x) write x,!'
echo '# Testing EXCEEDSPREALLOC error from gtm_char_t** by writing out of buffer range'
$gtm_dist/mumps -run %XCMD 'do &callOutChar(.x) write x,!'
echo '# Testing EXTCALLBOUNDS error from gtm_char_t** by writing out of buffer range'
echo '# this produces an expected core file'
$gtm_dist/mumps -run %XCMD 'do &callOutChar2(.x) write x,!'

set nonomatch=1  # prevent "no match" error if there are no core files below
set corefiles = ( core* )
if ( -e "$corefiles[1]" ) then
	foreach core ( core* )
		mv $core expected.$core
	end
endif
