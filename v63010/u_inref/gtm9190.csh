#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$echoline
echo "Verify a few of the more interesting (larger/complex) object files in ydb_dist with eu-elflint"
$echoline
echo "Running eu-elflint on GDEGET.o"
eu-elflint $ydb_dist/GDEGET.o
echo "Running eu-elflint on GDESHOW.o"
eu-elflint $ydb_dist/GDESHOW.o
echo "Running eu-elflint on GTMDefinedTypesInit.o"
eu-elflint $ydb_dist/GTMDefinedTypesInit.o
echo "Running eu-elflint on SCANTYPEDEFS.o"
eu-elflint $ydb_dist/SCANTYPEDEFS.o
echo "Running eu-elflint on _YDBENV.o"
eu-elflint $ydb_dist/_YDBENV.o
