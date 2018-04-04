#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test to verify whether the database has been encrypted or not
#

echo "#### Test if the encryption supported databases, journals, backups and extracts stores the data encrypted ####"
set NL = "echo "
$GDE change -s default -encr

$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out

$GDE <<xyz
add -name A* -reg=AREG
add -reg AREG -d=ASEG
add -seg ASEG -file=a.dat
xyz

echo "------------------------------------------------------------"
echo "Database layout - "
echo "AREG REGION - A to B : UNENCRYPTED"
echo "DEFAULT REGION - REST : ENCRYPTED"
echo "------------------------------------------------------------"
$MUPIP create

$NL
$NL
echo "Create journal files for the respective regions"
$MUPIP set $tst_jnl_str -reg "*" >&! jnl_output.out

$NL
echo "Update 2 globals to the database - one each for the unencrypted and encrypted databases"
$NL
$GTM << xyz
w "s ^thisIsEncryptedKey=abcdef_is_in_an_encrypted_database",!
s ^thisIsEncryptedKey="abcdef_is_in_an_encrypted_database"
w "s ^AkeyNotEncrypted=123456_is_in_an_unencrypted_database",!
s ^AkeyNotEncrypted="123456_is_in_an_unencrypted_database"
xyz

$NL
echo "---------------------------------------------"
echo "BYTESTREAM BACKUP for mumps.dat --> mumps.bak"
echo '$MUPIP backup -bytestream DEFAULT mumps.bak'
# Since backup renames and creates fresh journal files, redirect the output as otherwise
# YDB-I-JNLCREATE output will change depending on the random behaviour of tst_jnl_str (BEFORE or NOBEFORE)
$MUPIP backup -bytestream DEFAULT mumps.bak >&! bytebak.out
echo "---------------------------------------------"
$NL
$NL
echo "---------------------------------------------"
echo "COMPREHENSIVE BACKUP for mumps.dat --> mumps.co"
echo '$MUPIP backup -c DEFAULT mumps.co'
# Since backup renames and creates fresh journal files, redirect the output as otherwise
# YDB-I-JNLCREATE output will change depending on the random behaviour of tst_jnl_str (BEFORE or NOBEFORE)
$MUPIP backup -c DEFAULT mumps.co >&! comprebak.out
echo "---------------------------------------------"
$NL
$NL
echo "---------------------------------------------"
echo "BYTESTREAM BACKUP for a.dat --> a.bak"
echo '$MUPIP backup -bytestream DEFAULT a.bak'
$MUPIP backup -bytestream AREG a.bak >&! bytebak1.out
echo "---------------------------------------------"
$NL
$NL
echo "---------------------------------------------"
echo "COMPREHENSIVE BACKUP for a.dat --> a.co"
echo '$MUPIP backup -c DEFAULT a.co'
$MUPIP backup -c  AREG a.co >&! comprebak1.out
echo "---------------------------------------------"
$NL
$NL
echo "---------------------------------------------"
echo "BINARY EXTRACT for mumps.dat --> mumps.ext"
echo '$MUPIP extract -fo=bin -select="t*" mumps.ext'
$MUPIP extract -fo=bin -select="t*" mumps.ext
echo "---------------------------------------------"
$NL
$NL
echo "---------------------------------------------"
echo "BINARY EXTRACT for a.dat --> a.ext"
echo '$MUPIP extract -fo=bin -select="A*" a.ext'
$MUPIP extract -fo=bin -select="A*" a.ext
# On some solaris boxes (liza, for instance), strings utility doesn't catch all strings unless they are either null-terminated or
# has a newline at the end. The below hack appends a '\n' at the end. See <liza_strings_doesnt_catch_all_strings> for more details.
echo >>&! a.ext
echo "---------------------------------------------"


set cntr = 1
foreach ext (dat mjl ext bak co)
	if ($ext == "dat") then
		set type = "DATABASE FILES"
	else if ($ext == "mjl") then
		set type = "JOURNAL FILES"
	else if ($ext == "ext") then
		set type = "BINARY EXTRACT FILES"
	else if ($ext == "bak") then
		set type = "BYTESTREAM BACKUP FILES"
	else if ($ext == "co") then
		set type = "COMPREHENSIVE BACKUP FILES"
	endif
	$NL
	echo "STRINGS TEST FOR $type"
	echo "----------------------------------------------------------------"
	echo "Verify if ^thisIsEncryptedKey is stored encrypted in mumps.$ext"
	$strings mumps.$ext* >&! mumps_strings_$cntr.key
	$grep "thisIsEncryptedKey" mumps_strings.key >&! mumps_grep_$cntr.key
	set stat=$status
	if ($stat != 0) then
		echo "TEST-I-KEYNOTFOUND thisIsEncryptedKey not found in mumps.$ext* as expected"
	else
		echo "TEST-E-KEYFOUND thisIsEncryptedKey expected to be not seen in mumps.$ext* but found"
	endif
	echo "----------------------------------------------------------------"
	$NL
	$NL

	echo "----------------------------------------------------------------"
	echo "Verify if value - abcdef_is_in_an_encrypted_database is stored encrypted in mumps.$ext"
	$strings mumps.$ext* >&! mumps_strings_$cntr.val
	$grep "abcdef_is_in_an_encrypted_database" mumps_strings.val >&! mumps_grep_$cntr.val
	set stat=$status
	if ($stat != 0) then
		echo "TEST-I-VALUENOTFOUND abcdef_is_in_an_encrypted_database not found in mumps.$ext* as expected"
	else
		echo "TEST-E-VALUEFOUND abcdef_is_in_an_encrypted_database expected to be not seen in mumps.$ext* but found"
	endif
	echo "----------------------------------------------------------------"
	$NL
	$NL
	echo "----------------------------------------------------------------"
	echo "Verify if ^AkeyNotEncrypted is present in a.$ext"
	$strings  a.$ext* >&! a_strings_$cntr.key
	$grep "AkeyNotEncrypted" a_strings_$cntr.key >&! a_grep_$cntr.key
	set stat=$status
	if ($stat != 0) then
		echo "TEST-E-KEYNOTFOUND AkeyNotEncrypted expected to be found in a.$ext* but not seen"
	else
		echo "TEST-I-KEYFOUND AkeyNotEncrypted found in a.$ext* as expected"
	endif
	echo "----------------------------------------------------------------"
	$NL
	$NL

	echo "----------------------------------------------------------------"
	echo "Verify if value - 123456_is_in_an_unencrypted_database is present in a.$ext"
	$strings  a.$ext* >&! a_strings_$cntr.val
	$grep "123456_is_in_an_unencrypted_database" a_strings_$cntr.val >&! a_grep_$cntr.val
	set stat=$status
	if ($stat != 0) then
		echo "TEST-E-VALUENOTFOUND 123456_is_in_an_unencrypted_database expected to be found in a.$ext* but not seen"
	else
		echo "TEST-I-VALUEFOUND 123456_is_in_an_unencrypted_database found in a.$ext* as expected"
	endif
	echo "----------------------------------------------------------------"
	$NL
	$NL
	@ cntr = $cntr + 1
end
