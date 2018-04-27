#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################
#
# Test different settings for gtm_chset and $ZCHSET (valid and invalid)
#
$gtm_tst/com/dbcreate.csh mumps 1
#
source $gtm_tst/$tst/u_inref/test_chset.csh "whatever" "M"
source $gtm_tst/$tst/u_inref/test_chset.csh "UTF-8" "UTF-8"
source $gtm_tst/$tst/u_inref/test_chset.csh "utf-8" "UTF-8"
source $gtm_tst/$tst/u_inref/test_chset.csh "binary" "M"
source $gtm_tst/$tst/u_inref/test_chset.csh "m" "M"
source $gtm_tst/$tst/u_inref/test_chset.csh "MUTF-8" "M"
$echoline
echo "SVNOSET error expected here"
$GTM << EOF >&! svnoset.out
set \$ZCHSET="M"
EOF
$gtm_tst/com/check_error_exist.csh svnoset.out SVNOSET
$switch_chset "UTF-8"
$echoline
echo "Testing gtm_chset with UTF-8"
$GTM << EOF
write \$ZCHSET,!
write "Testing two byte א",!
set ^HebrewAlef=\$CHAR(1488) ; א
do ^examine(1,\$LENGTH(^HebrewAlef),"\$LENGTH of ^HebrewAlef is 1")
do ^examine(1488,\$ASCII(^HebrewAlef),"\$ASCII of ^HebrewAlef is 1488")
do ^examine("א",\$CHAR(1488),"\$CHAR(1488) is א")
write "Testing three byte ☺",!
set ^strsmiley=\$ZCHAR(226,152,186) ; ☺
do ^examine(1,\$LENGTH(^strsmiley),"\$LENGTH of ^strsmiley is 1")
do ^examine(9786,\$ASCII(^strsmiley),"\$ASCII of ^strsmiley is 9786")
do ^examine("ａ",\$CHAR(65345),"\$CHAR(65345) is ａ")
write "Testing four byte 𝐀",!
set ^MathematicalA=\$ZCHAR(240,157,144,128) ; 𝐀
do ^examine(1,\$LENGTH(^MathematicalA),"\$LENGTH of ^MathematicalA is 1")
do ^examine(119808,\$ASCII(^MathematicalA),"\$ASCII of ^MathematicalA is 119808")
do ^examine("𝐀",\$CHAR(119808),"\$CHAR(119808) is 𝐀")
write "Testing an invalid character ",!
view "NOBADCHAR"
set ^invalid=\$ZCHAR(199,199,199) ; invalid
do ^examine(3,\$LENGTH(^invalid),"\$LENGTH of ^invalid is 3")
do ^examine(-1,\$ASCII(^invalid),"\$ASCII of ^invalid is NULL")
EOF
#
foreach x (M binary)
	$switch_chset $x
	$echoline
	echo "Testing gtm_chset with $x"
	# because of LC_ALL being set to C we cannot write some unicode lieterals as such
	# so just have two,three,four byte indications and not print the actual literal in the write statement
$GTM << EOF
write \$ZCHSET,!
write "Testing two byte",!
do ^examine(2,\$LENGTH(^HebrewAlef),"\$LENGTH of ^HebrewAlef is 2")
do ^examine(215,\$ASCII(^HebrewAlef),"\$ASCII of ^HebrewAlef is 215")
do ^examine("",\$CHAR(1488),"\$CHAR(1488) is null string")
write "Testing three byte",!
do ^examine(3,\$LENGTH(^strsmiley),"\$LENGTH of ^strsmiley is 3")
do ^examine(226,\$ASCII(^strsmiley),"\$ASCII of ^strsmiley is 226")
do ^examine("",\$CHAR(65345),"\$CHAR(65345) is a null string")
write "Testing four byte",!
do ^examine(4,\$LENGTH(^MathematicalA),"\$LENGTH of ^MathematicalA is 4")
do ^examine(240,\$ASCII(^MathematicalA),"\$ASCII of ^MathematicalA is 240")
do ^examine("",\$CHAR(119808),"\$CHAR(119808) is null string")
write "Testing an invalid character ",!
set ^invalid=\$CHAR(199,199,199) ; invalid
do ^examine(3,\$LENGTH(^invalid),"\$LENGTH of ^invalid is 3")
do ^examine(199,\$ASCII(^invalid),"\$ASCII of ^invalid is 199")
EOF
#
end
# test that ^%PATCODE errors out if gtm_chset is UTF-8
$switch_chset "UTF-8"
echo "Try and load a pattable that has 128 and above code in it"
# create a dummy pat table that will have no effect
cat << EOF > pattable
PATSTART
	PATTABLE DUMMY
	  PATCODE B
	    48,49,50,51,152,53,54,55,56,57
PATEND
EOF

source $gtm_tst/com/set_ydb_env_var_random.csh ydb_pattern_file gtm_pattern_file "pattable"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_pattern_table gtm_pattern_table "DUMMY"
$GTM << EOF >&! patcode_error.out
EOF
#
$gtm_tst/com/check_error_exist.csh patcode_error.out "PATTABSYNTAX"
#
source $gtm_tst/com/unset_ydb_env_var.csh ydb_pattern_file gtm_pattern_file
$gtm_tst/com/dbcheck.csh
