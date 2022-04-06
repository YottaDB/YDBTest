#!/usr/local/bin/tcsh -f
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

echo "# This test runs MUPIP BACKUPs with backup directory paths from"
echo "# 220 to 265 characters where there are 2 database files with"
echo "# separate names, regions and segments. The backups are run with"
echo "# and without the -noonline option. The expected result is for"
echo "# paths of 255 or less to work but for paths of more than 255"
echo "# to result in errors."

cat > gen.m << CAT_EOF
 for i=1:1:+\$zcmdline write \$extract("habcdefg",1+(i#8))
CAT_EOF

$echoline
echo "# Setting up the global directory mumps.gld and creating the"
echo "# databases mumps.dat and a.dat from that global directory."

setenv gtmgbldir mumps.gld
rm -f mumps.gld mumps.dat a.dat
$gtm_dist/mumps -run GDE << GDE_EOF
change -segment DEFAULT -file=mumps.dat
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a
GDE_EOF

$gtm_dist/mupip create

@ cnt = 220


$echoline
echo "# Starting the -noonline MUPIP BACKUPs. For these, we"
echo "# generate directory paths of 220 to 266 characters,"
echo "# expecting lengths of 220 to 233 to succeed and longer"
echo "# lengths to result in errors. Lengths of 234 or larger"
echo "# fail due to the space needed for the temporary file which"
echo "# would otherwise overflow a buffer in sr_port/mubfilcpy.c"

while ($cnt < 266)
	set dirname = `$gtm_dist/mumps -run gen $cnt`
	rm -rf $dirname
	mkdir $dirname
	echo "####### Testing backup directory length [$cnt] with -noline #########"
	$gtm_dist/mupip backup -noonline "*" $dirname
	rm -rf $dirname
	@ cnt = $cnt + 1
end

$echoline
echo "# Starting the online MUPIP BACKUPs. For these, we generate"
echo "# directory paths of 220 to 266 characters including the"
echo "# length of the test directory. The test directory is included"
echo "# in the length for these backups because online backups use the"
echo "# full directory path for the temporary file. This means that a"
echo "# backup directory length of even 220 would always generate an"
echo "# error if run from the test directory. Setting the minimum of"
echo "# the range to a lower number wouldn't work because the length of"
echo "# the test directory can vary based on factors such as the build"
echo "# name and which user is running the test which would make it"
echo "# impossible to predict where the FILENAMETOOLONG errors should"
echo "# first show up. So we subtract the length of the test dir from"
echo "# the directory length to ensure predictable results in this"
echo "# section of the test. We expect a path, including the test"
echo "# of 230 or more characters to produce a FILENAMETOOLONG error"
@ cnt = 220
set testdir=`pwd`
set testdirlength=`echo $testdir | awk '{print length($0)}'`

while ($cnt < 266)
	@ len=($cnt - $testdirlength)
	set dirname = `$gtm_dist/mumps -run gen $len`
	rm -rf $dirname
	mkdir $dirname
	echo "####### Testing backup directory length [$cnt] (online backup) #########"
	$gtm_dist/mupip backup "*" $dirname
	rm -rf $dirname
	@ cnt = $cnt + 1
end

@ cnt = 230

$echoline
echo "# Starting backups with path lengths from 230 to 235 testing"
echo "# MUPIP BACKUP -noonline -bytestream -since= where since is"
echo '# equal to either incremental, database, record or "". These'
echo "# backups used to generate errors on ASAN builds due to a memcmp"
echo "# bug that was fixed by YDB#864."
while ($cnt < 236)
        $gtm_dist/mumps -direct << GTM_EOF
                set ^a=1,^x=1
GTM_EOF

        set dirname = `$gtm_dist/mumps -run gen $cnt`
        echo "####### Testing backup directory length [$cnt] with noonline, bytestream and since= #########"
        foreach since (incremental database record "")
                rm -rf $dirname
                mkdir $dirname
                if ("" == "$since") then
                        set sincequal = ""
                else
                        set sincequal = "-since=$since"
                endif
                echo "############ Testing $sincequal"
                $gtm_dist/mupip backup -noonline "*" -bytestream $sincequal $dirname
        end
        rm -rf $dirname
        @ cnt = $cnt + 1
end


$echoline
$gtm_tst/com/dbcheck.csh
