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
#
# Test "ZHALT rc" command for correct functioning. Three types of ZHalt return codes tested over
# a range of potential return codes. Note since the maximum retcode we can see is 255, the test
# verifies that "rollover" return codes still show as an error rather than truncating 256 to 0.
#
# Note stdout from GTM is dropped as this test has no stdout output of note (besides several hundred
# YDB> prompts). Any errors will show up in the tests log and be flagged.
#
@ rc = 0
while (257 > $rc)
    # First check using simple numeric rc
    $GTM << EOF > /dev/null
    ZHalt $rc
EOF
    set saverc = $status
    if ((256 != $rc) && ($saverc != $rc)) then
	echo "Simple numeric check: Expecting return code $rc but got return code $saverc instead"
	exit 1
    else if ((256 == $rc) && (255 != $saverc)) then  # if modulo($saverc,256) would be zero, $saverc is set to 255 instead
	echo "Simple numeric check: Expecting return code 255 but got return code $saverc instead"
	exit 1
    endif
    # Next check using var with numeric value
    $GTM << EOF > /dev/null
    Set rc=$rc
    ZHalt rc
EOF
    set saverc = $status
    if ((256 != $rc) && ($saverc != $rc)) then
	echo "Numeric var check: Expecting return code $rc but got return code $saverc instead"
	exit 1
    else if ((256 == $rc) && (255 != $saverc)) then  # if modulo($saverc,256) would be zero, $saverc is set to 255 instead
	echo "Numeric val check: Expecting return code 255 but got return code $saverc instead"
	exit 1
    endif
    # Next check using indirect var with numeric value
    $GTM << EOF > /dev/null
    Set rc=$rc
    Set xrc="rc"
    ZHalt @xrc
EOF
    set saverc = $status
    if ((256 != $rc) && ($saverc != $rc)) then
	echo "Indirect var check: Expecting return code $rc but got return code $saverc instead"
	exit 1
    else if ((256 == $rc) && (255 != $saverc)) then  # if modulo($saverc,256) would be zero, $saverc is set to 255 instead
	echo "Indirect var check: Expecting return code 255 but got return code $saverc instead"
	exit 1
    endif
    @ rc = $rc + 1
end
echo "ZHalt test passed"
