#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# Test that $TEXT on M program compiled with the embed_source flag does not include $C(13) at the end of the source line.'
echo "# Write to a UNIX M file."
echo ' write 1234' > x.m
# Remove backslash functionality for perl.
set backslash_quote
echo "# Convert the UNIX M file into a DOS M file."
perl -p -e 's/\n/\r\n/' x.m > xdos.m
echo '# Compile the DOS M file without Embed_Source flag, run $TEXT on it and zwrite the returned line. It should not contain $C(13).'
set verbose
$ydb_dist/mumps -run ^%XCMD 'zcompile "xdos.m"  set srcline=$text(^xdos)  zwr srcline'
unset verbose
echo '# Compile the DOS M file with Embed_Source flag, run $TEXT on it and zwrite the returned line. It should not contain $C(13).'
set verbose
$ydb_dist/mumps -run ^%XCMD 'zcompile "-embed_source xdos.m"  set srcline=$text(^xdos)  zwr srcline'
unset verbose
