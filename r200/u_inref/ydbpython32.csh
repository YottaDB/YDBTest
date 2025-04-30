#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Clone YDBPython
echo "# Starting test for CTRL-C on Interactive (started from terminal) Flask Application terminates properly"
echo "# Cloning and Installing YDBPython"
git clone -q https://gitlab.com/YottaDB/Lang/YDBPython.git
cd YDBPython

# Create Python virtual environment:
echo "# Setting up Virtual environment and installing flask"
python3 -m venv .venv
set prompt=""
source .venv/bin/activate.csh

# See comment in com/setuppyenv.csh for why this step is needed
pip install setuptools >& setup.txt

# Install into venv: `python -m pip install .`
python -m pip install . >>&  setup.txt
pip3 install flask      >>& setup.txt

# Make sure that the ldd linkage is right
echo "# Verify that YDBPython linked against the correct version of YottaDB"
find .venv -name '*.so' -exec ldd {} \; | grep libyottadb.so

echo "# Creating db file"
$gtm_tst/com/dbcreate.csh mumps

cp $gtm_tst/r136/inref/ydb935-1.py index.py

echo "# Running expect script simulating two sessions with CTRL-C at the end for flask"
(expect -d $gtm_tst/$tst/u_inref/ydbpython32.exp > expect.out) >& expect.dbg
perl $gtm_tst/com/expectsanitize.pl expect.out > expect_sanitized.out
grep "YDB-SUCCESS" expect_sanitized.out
