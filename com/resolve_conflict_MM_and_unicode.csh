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

# ICU and MM restrictions can cause random_ver to fail. Since random_ver
# selects MM ahead of UTF-8, force M mode when the host is using the
# new ICU naming scheme. This assumes that hosts using the new ICU naming
# scheme do not have ICU 3.6 installed.
$gtm_tst/com/is_icu_new_naming_scheme.csh
set disable_utf8 = $status
if (0 == $disable_utf8 && "MM" == "$acc_meth") then
       $switch_chset M >&! disable_utf8.txt
endif
