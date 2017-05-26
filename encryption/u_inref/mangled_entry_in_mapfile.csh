#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test for valid entry and format for mapping file

# Set white box testing environment.
echo "# Enable WHITE BOX TESTING"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22

setenv gtmgbldir ./create.gld
$gtm_tst/com/dbcreate.csh create 3
cp $gtm_tst/encryption/inref/temp.gde .
$GDE << EOF
@./temp.gde
EOF

cat > mupip_create1.csh << EOF
$MUPIP create -reg=areg
$MUPIP create -reg=default
$MUPIP create -reg=yreg
echo
EOF

cat > mupip_create2.csh << EOF
$MUPIP create
echo
EOF

chmod 755 mupip_create*.csh
echo

@ i = 0
while ($i < 2)
@ i = $i + 1
##############################
#Test1

echo "Test${i}.1-- 'database' => 'databases'"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
databases : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test2

echo "Test${i}.2-- Missing curly brace"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database :
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test3

echo "Test${i}.3-- Missing parentheses"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : {
		dat: "create.dat";
		key: "create_dat_key";
	} ;
};
EOF
mupip_create${i}.csh

##############################
#Test4

echo "Test${i}.4-- 'dat' => 'dAt'; 'key' => 'kEy'"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dAt: "create.dat";
		kEy: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test5

echo "Test${i}.5-- Empty keys set"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	}, {
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test6

echo "Test${i}.6-- Missing 'dat' field"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test7

echo "Test${i}.7-- Missing 'key' field"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test8

echo "Test${i}.8-- Extraneous field"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
		bam: "mumps.bam";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test9

echo "Test${i}.9-- Missing quotes"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: create.dat;
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test10

echo "Test${i}.10-- Missing colons"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat "create.dat";
		key "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
#Test11

echo "Test${i}.11-- Missing keys section"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
};
EOF
mupip_create${i}.csh

##############################
# Test12

echo "Test${i}.12-- Dat points to an invalid path"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "invalid/path/create.dat";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test13

echo "Test${i}.13-- Key points to an invalid path"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "invalid/path/create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test14

echo "Test${i}.14-- Dat points to something other than a database file"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create_dat_key";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test15

echo "Test${i}.15-- Key points to something other than a symmetric key"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "gtmcrypt.cfg";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test16

echo "Test${i}.16-- Same database listed twice with different keys"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	},{
		dat: "create.dat";
		key: "a_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test17

echo "Test${i}.17-- Same database listed twice with the same key"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	},{
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test18

echo "Test${i}.18-- Database path is very long (over 4096)"
\rm -rf *.dat
$gtm_dist/mumps -run %XCMD 'write "dat: """ do ^%RANDSTR(4097) write "/create.dat"";",!' > long
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
EOF
cat long >> gtmcrypt.cfg
cat >> gtmcrypt.cfg << EOF
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test19

echo "Test${i}.19-- Key path for database is very long (over 4096)"
\rm -rf *.dat
$gtm_dist/mumps -run %XCMD 'write "key: """ do ^%RANDSTR(4097) write "/create_dat_key"";",!' > long
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
EOF
cat long >> gtmcrypt.cfg
cat >> gtmcrypt.cfg << EOF
	} );
};
EOF
mupip_create${i}.csh

##############################
# Test20

echo "Test${i}.20-- Key path for devices is very long (over 4096)"
\rm -rf *.dat
$gtm_dist/mumps -run %XCMD 'write "mumps: """ do ^%RANDSTR(4097) write "/create_dat_key"";",!' > long
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
files : {
EOF
cat long >> gtmcrypt.cfg
cat >> gtmcrypt.cfg << EOF
};
EOF
mupip_create${i}.csh

##############################
# Test21

echo "Test${i}.21-- Key name for devices is very long (over 4096)"
\rm -rf *.dat
$gtm_dist/mumps -run %XCMD 'do ^%RANDSTR(4097) write "/mumps: ""create_dat_key"";",!' > long
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
files : {
EOF
cat long >> gtmcrypt.cfg
cat >> gtmcrypt.cfg << EOF
};
EOF
mupip_create${i}.csh

##############################
# Test22

echo "Test${i}.22-- Several keyname fields are identical"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	}, {
		dat: "a.dat";
		key: "create_dat_key";
	}, {
		dat: "b.dat";
		key: "create_dat_key";
	} );
};
EOF
mupip_create${i}.csh
##############################
# Test23

echo "Test${i}.23-- Empty braces after database block"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
        keys: ( {
		dat: "create.dat";
		key: "create_dat_key";
      	} );
};{};
EOF
mupip_create${i}.csh

##############################
# Test24

echo "Test${i}.24-- Multiple dat entries within a key set"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
         keys: ( {
		dat: "create.dat";
		dat: "a.dat";
		key: "create_dat_key";
        } );
};
EOF
mupip_create${i}.csh

##############################
# Test25

echo "Test${i}.25-- Multiple key entries within a key set"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
          keys: ( {
		dat: "create.dat";
		key: "create_dat_key";
		key: "create_dat_key";
          } );
};
EOF
mupip_create${i}.csh

##############################
# Test26

echo "Test${i}.26-- Multiple key,dat entries within a key set"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
          keys: ( {
		dat: "create.dat";
		key: "create_dat_key";
		dat: "a.dat";
		key: "a_dat_key";
          } );
};
EOF
mupip_create${i}.csh

##############################
# Test27

echo "Test${i}.27-- Filename fields are identical"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	} );
};
files : {
	mumps: "create_dat_key";
	mumps: "a_dat_key";
};
EOF
mupip_create${i}.csh
##############################
# Test28

echo "Test${i}.28-- Empty braces and a tls block after database section"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
        keys: ( {
		dat: "create.dat";
		key: "create_dat_key";
      	} );
};{};
tls: {
};
EOF
mupip_create${i}.csh
##############################
# Test29

echo "Test${i}.29-- Empty tls block"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database: {
        keys: ( {
		dat: "create.dat";
		key: "create_dat_key";
      	} );
};
tls: {
};
EOF
mupip_create${i}.csh

##############################
# Test30

echo "Test${i}.30-- Normal setup"
\rm -rf *.dat
cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "create.dat";
		key: "create_dat_key";
	}, {
		dat: "a.dat";
		key: "a_dat_key";
	}, {
		dat: "b.dat";
		key: "b_dat_key";
	} );
};
EOF
$MUPIP create -reg=areg
$MUPIP create -reg=breg
$MUPIP create -reg=default
$MUPIP create -reg=yreg
$MUPIP create -reg=zreg
echo

$gtm_tst/com/dbcheck.csh
echo
end
