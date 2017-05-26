#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test Case for TR:C9903-000899"
echo "Journal filename containing . in directory name"
# not using dbcreate.csh since complicated GLD and encryption setup.
set cur_dir = `pwd`
#
$GDE << EOF
ch -seg DEFAULT -file=$cur_dir/mumps.dat
exit
EOF

if ("ENCRYPT" == "$test_encryption" ) then
	setenv gtmcrypt_config $cur_dir/gtmcrypt.cfg
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

setenv gtmgbldir $cur_dir/mumps.gld
$MUPIP create
#
echo "Create directories: a.b, a.b.c, a.b.c.d, e..f"
\mkdir ./a.b
\mkdir ./a.b.c
\mkdir ./a.b.c.d
\mkdir ./e..f
#
echo '--------------------------------------------------------------'
echo 'MUPIP set -journal=enable,nobefore,filename="./a.b/c.mjl" -file mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="./a.b/c.mjl" -file mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
echo '$MUPIP set -journal=enable,nobefore,filename="a.b/c.d" -file mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="a.b/c.d" -file mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
echo '$MUPIP set -journal=enable,nobefore,filename="./a.b.c/d.mjl" -file mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="./a.b.c/d.mjl" -file mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
echo '$MUPIP set -journal=enable,nobefore,filename="./e..f/mumps.mjl" -file mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="./e..f/mumps.mjl" -file mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
#
cd ./a.b
# Note gtmgbldir must have absoulute path to database
echo '$MUPIP set -journal=enable,nobefore,filename="$cur_dir/a.b.c.d/mumps.mjl" -file $cur_dir/mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="$cur_dir/a.b.c.d/mumps.mjl" -file $cur_dir/mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
echo '$MUPIP set -journal=enable,nobefore,filename="../a.b.c/d2.jnl" -file $cur_dir/mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="../a.b.c/d2.jnl" -file $cur_dir/mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
echo '$MUPIP set -journal=enable,nobefore,filename="../c.d/failed.mjl" -file mumps.dat'
$MUPIP set -journal=enable,nobefore,filename="../c.d/failed.mjl" -file $cur_dir/mumps.dat
$DSE dump -fileheader |& $grep "Journal File"
echo '--------------------------------------------------------------'
#
$gtm_tst/com/dbcheck.csh
