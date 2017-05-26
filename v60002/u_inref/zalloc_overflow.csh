#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test verifies that no overflows happen in $zrealstor, $zallocstor, and $zusedstor calculations.
# The test relies on white-box logic to first get the size of size_t structure on the current box, and
# then assign increasingly high values to internal containers for $zrealstor, $zallocstor, and
# $zusedstor to ensure they experience no overflows.

# Prepare the environment for the white-box test that yields huge allocation values.
setenv gtm_white_box_test_case_number 89
setenv gtm_white_box_test_case_enable 1

# The first case just tells us how big size_t is.
setenv gtm_white_box_test_case_count 0

$gtm_exe/mumps -direct >&! "size_t.outx" << EOF
  zsystem "echo "_\$zrealstor_" > size_t.txt"
EOF

@ size_t = `cat size_t.txt`

# In the second case we see how (2 * 0xffff) gets displayed.
setenv gtm_white_box_test_case_count 1

$gtm_exe/mumps -direct >&! "gtm1.outx" << EOF
  write "ZREALSTOR is "_\$zrealstor,!
  write "ZALLOCSTOR is "_\$zallocstor,!
  write "ZUSEDSTOR is "_\$zusedstor,!
EOF

$grep 131070 gtm1.outx

# In the third case we see how (2 * 0xfffffff) gets displayed.
setenv gtm_white_box_test_case_count 2

$gtm_exe/mumps -direct >&! "gtm2.outx" << EOF
  write "ZREALSTOR is "_\$zrealstor,!
  write "ZALLOCSTOR is "_\$zallocstor,!
  write "ZUSEDSTOR is "_\$zusedstor,!
EOF

$grep 536870910 gtm2.outx

# In the final, fourth case we try to display either (2 * 0xfffffff) or (2 * 0xfffffffffffffff),
# depending on whether size_t is 8 or 4 bytes.
setenv gtm_white_box_test_case_count 3

$gtm_exe/mumps -direct >&! "gtm3.outx" << EOF
  write "ZREALSTOR is "_\$zrealstor,!
  write "ZALLOCSTOR is "_\$zallocstor,!
  write "ZUSEDSTOR is "_\$zusedstor,!
EOF

# We check against 16, not 8, because the size of size_t gets doubled in the white-box test logic.
if (16 == $size_t) then
	$grep 2305843009213693950 gtm3.outx
else
	$grep 536870910 gtm3.outx
endif
