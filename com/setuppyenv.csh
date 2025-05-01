#################################################################
#								#
# Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	#
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
set status1 = $status
if ($status1) then
	echo "SETUPPYENV-E-FAILED : [source .venv/bin/activate.csh] failed with status [$status1]"
	cd ..
	exit 1
endif
# setuptools is no longer pre-installed in virtual environments created with venv from Python 3.12
# This means that it is no longer available by default. But since setup.py needs it, run the
# following in the activated virtual environment. See https://docs.python.org/3/whatsnew/3.12.html
# for more details (search for "gh-95299").
pip install setuptools
set status1 = $status
if ($status1) then
	echo "SETUPPYENV-E-FAILED : [pip install setuptools] failed with status [$status1]"
	cd ..
	exit 1
endif
# Install into venv: `python -m pip install .`
python -m pip install .
set status1 = $status
if ($status1) then
	echo "SETUPPYENV-E-FAILED : [python -m pip install .] failed with status [$status1]"
	cd ..
	exit 1
endif
cd ..
exit 0
