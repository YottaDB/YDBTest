#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This script is meant to be sourced by Python tests to build the YDBPython wrapper
# before running the specific YDBPython test. The commands here assume that `python3`,
# `python3-pip`, and `python3-venv` have been installed on the host system.

set tstpath = `pwd`
set pypath = $tstpath/python
setenv PKG_CONFIG_PATH $ydb_dist

git clone https://gitlab.com/YottaDB/Lang/YDBPython.git $pypath
@ status1 = $status
if ($status1) then
	echo "SETUPPYENV-E-FAILED : [git clone https://gitlab.com/YottaDB/Lang/YDBPython.git $pypath] failed with status = [$status1]"
	exit $status1
endif
cd $pypath
# Create Python virtual environment:
python3 -m venv .venv
# Activate virtual environment
source .venv/bin/activate.csh
# Install into venv: `python setup.py install`
python setup.py install
cd ..
exit 0
