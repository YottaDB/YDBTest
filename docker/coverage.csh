#!/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
if ( $?calculate_coverage ) then
	if ( ! $?CI_PROJECT_DIR ) set CI_PROJECT_DIR = .
	gcovr --xml-pretty --exclude-unreachable-branches --print-summary -o=$CI_PROJECT_DIR/coverage-gcovr.xml --gcov-ignore-parse-errors --root=/Distrib/YottaDB/V999_R999/ /Distrib/YottaDB/V999_R999/dbg
	sed "s|<source>.*</source>|<source>${CI_PROJECT_DIR}</source>|" $CI_PROJECT_DIR/coverage-gcovr.xml > $CI_PROJECT_DIR/coverage.xml
endif
