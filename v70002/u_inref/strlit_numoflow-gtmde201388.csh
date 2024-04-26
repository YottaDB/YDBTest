#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

cat << 'CAT_EOF' | sed 's/^/# /;'
********************************************************************************************
GTM-DE201388 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637468)

$[Z]CHAR(1E48) and similar numeric literal overflows produce a NUMOFLOW error at compile time;
previously an optimization inappropriately treated this as $[Z]CHAR(0). (GTM-DE201388)

'CAT_EOF'

echo ''
setenv ydb_msgprefix "GTM"

echo '# GT.M release note is inaccurate. It needs to say "1E48" instead of 1E48.'
echo '# Discussion in https://gitlab.com/YottaDB/DB/YDBTest/-/issues/581#note_1881352659'
echo '# This test used to fail in GT.M version prior to V7.0-002 with wrong output "x=$C(0)"'
echo '# GT.M Version after V7.0-002 and later will issue NUMOFLOW error.'
echo ''
$gtm_exe/mumps -run %XCMD 'set x=$char("1E48") zwrite x'
