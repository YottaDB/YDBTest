#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.  	#
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
# This script provides a comparison between two extract files with mupip extract content.
# Steps performed:
# 1) Filter the variable part of $1 and $2 which are
#	- Path info in line 1 of default label
#	- Time info in line 2 of default label
# 2) Compares filtered $1 and $2
# Arguments:
# 	$1 - first file
# 	$2 - second file
if ( $#argv != 2 ) then
        echo ""
        echo "USAGE of  extractdiff.csh"
        echo "extractdiff.csh <extractfile1> <extractfile2>"
        echo ""
        exit 1
endif

set ext1=$1:e
set ext2=$2:e

if ($ext1 != $ext2) then
	echo "\nFile extensions are different $1 $2"
	exit 1
endif

if ($ext1 != "bin") then
	foreach file ($1 $2)
		sed '2s/.*/##TIMESTAMP_FILTERED/' $file > filtered_header.txt
		sed 's/YottaDB MUPIP EXTRACT.*/YottaDB MUPIP EXTRACT/g' filtered_header.txt >>&! $file.filtered
		rm filtered_header.txt
	end
endif

if ($ext1 == "bin") then
	cmp --ignore-initial=100 $1 $2	# Header information (first 100 bytes) is ignored
else
	diff $1.filtered $2.filtered
endif

