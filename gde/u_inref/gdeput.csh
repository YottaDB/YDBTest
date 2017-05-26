#!/usr/local/bin/tcsh -f
# this verifies that gde will write to the appropriate .gld file
# cases: test when gtmgbldir is undefined and:
#               .gld does not exist then setgd=same, make change
#		.gld exists then setgd=same, make change
#				setgd=new, make change
#
#	 test when gtmgbldir is defined and:
#               .gld does not exist then setgd=same, make change
#               .gld exists then setgd=same, make change
#                               setgd=new, make change
#
#	tests should not produce write errors and should create the .gld's
#
echo "Begin write tests of gde..."
unsetenv gtmgbldir 
echo "undefined and doesn't exist - set to same..."
ls *.gld
echo gtmgbldir is not defined: $?gtmgbldir
$gtm_exe/mumps -run GDE << \_GDE_EOF 
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "undefined and does exist - set to same..."
ls *.gld
$gtm_exe/mumps -run GDE << \_GDE_EOF 
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "undefined create new .gld set to same make change..."
ls *.gld
$gtm_exe/mumps -run GDE << \_GDE_EOF
setgd -f="mumps.gld"
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "defined and doesn't exist - set to same..."
rm *.gld
setenv gtmgbldir "acct.gld"
echo "gtmgbldir is defined : $gtmgbldir ($?gtmgbldir)"
ls *.gld
$gtm_exe/mumps -run GDE << \_GDE_EOF 
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "defined and exists set to same..."
ls *.gld
$gtm_exe/mumps -run GDE << \_GDE_EOF
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "defined create new .gld set to same make change..."
ls *.gld
$gtm_exe/mumps -run GDE << \_GDE_EOF
setgd -f="mumps.gld"
setgd -f="acct.gld"
change -segment DEFAULT -file_name=acct.dat
change -region DEFAULT -key_size=100
\_GDE_EOF

echo "the *.gld's are:"
ls *.gld

echo "End write tests of gde..."
