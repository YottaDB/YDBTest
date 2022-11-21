#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Clone YDBPython
echo "# Cloning and Installing YDBPython"
git clone -q https://gitlab.com/YottaDB/Lang/YDBPython.git
cd YDBPython

# Create Python virtual environment:
python3 -m venv .venv
# Activate virtual environment
set prompt=""
source .venv/bin/activate.csh

# Install into venv: `python setup.py install`
python setup.py install >&  setup.txt
pip3 install flask      >>& setup.txt

# Make sure that the ldd linkage is right
echo "# Verify that YDBPython linked against the correct version of YottaDB"
find .venv -name '*.so' -exec ldd {} \; | grep libyottadb.so

echo "# Creating db file"
$gtm_tst/com/dbcreate.csh mumps 3

if ($gtm_test_libyottadb_asan_enabled) then
	# Set ASAN variables
	setenv LD_PRELOAD `gcc -print-file-name=libasan.so`
	source $gtm_tst/com/set_asan_options_env_var.csh
endif

echo "# Running thread test..."
cp $gtm_tst/$tst/inref/ydb935-2.py thread.py
python3 thread.py

echo "# Running flask test..."
cp $gtm_tst/$tst/inref/ydb935-1.py index.py
setenv FLASK_APP "index"

echo "# Starting Flask..."
# Port=0 randomizes the start-up port for flask
(python3 -m flask run --host=127.0.0.1 --port=0 >& flask_output.txt & ; echo $! >&! flask.pid) >&! flask.out
set flaskpid = `cat flask.pid`
# Flask outputs this line: * Running on http://192.168.192.207:54003/ (Press CTRL+C to quit)
# https://stackoverflow.com/questions/25959870/how-to-wait-till-a-particular-line-appears-in-a-file
tail -f flask_output.txt | sed '/Press CTRL+C to quit/ q' > /dev/null
set flaskport = `grep "Running on http" flask_output.txt | cut -d: -f3 | cut -d/ -f1`

echo "# Getting data/saving data via Flask API"
curl -sS -H "Content-Type: application/json" -X GET localhost:$flaskport/users
curl -sS -H "Content-Type: application/json" -X POST localhost:$flaskport/adduser -d '{ "name": "Sam", "age": "30", "sex": "M" }'
echo ""

echo "# Extracting data to verify that data got saved"
$gtm_dist/mupip extract -stdout -select=^PATIENTS

echo "# Killing 3 region data (^a, ^b, ^c)"
$gtm_dist/yottadb -r %XCMD 'kill ^a,^b,^c'

echo "# Setting & Getting random globals"
$gtm_dist/yottadb -r %XCMD "do ^ydb935($flaskport)"

$gtm_dist/yottadb -r %XCMD 'write "# $data of ^a,^b,^c is ",$data(^a)," ",$data(^b)," ",$data(^c),!'

echo "# Killing off Flask process"
kill -9 $flaskpid
$gtm_tst/com/wait_for_proc_to_die.csh $flaskpid
