#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#Testing File accessibility: configuration file, obfuscation file, symmetric key file, and keyring file.


############################################################
# Creates the reference output file of the expected output #
############################################################

echo "file_access_checker input: $1 $2 $3 $4 $5" >> $file

set outfile 		= $1
set invalidSymkeyFlag 	= $2
set invalidKeyringFlag 	= $3
set invalidConfigFlag 	= $4
set emptySymkeyFlag	= $5
set msg = "Database file $PWD/mumps.dat created"

# Check if file has read(-r) permissions, file exists(-e), file is empty(-s) and its validity
if (!(-r $GNUPGHOME)) then
	set msg = 'No read permissions on $GNUPGHOME'
else if (!(-e gtmcrypt.cfg)) then
	set msg = "Cannot stat configuration file: gtmcrypt.cfg. No such file or directory"
else if (!(-s gtmcrypt.cfg)) then
	set msg = "Configuration file gtmcrypt.cfg contains neither 'database.keys' section nor 'files' section, or both sections are empty."
else if (!(-r gtmcrypt.cfg)) then
	set msg = "Cannot read config file gtmcrypt.cfg. At line# LINUM - file I/O error"
else if ($invalidConfigFlag == 1) then
	set msg = "Cannot read config file gtmcrypt.cfg. At line# LINUM - syntax error"
else if (!(-e mumps.key)) then
	set msg = "In config file gtmcrypt.cfg, could not obtain the real path of 'database.keys' entry #1's key"
else if ($emptySymkeyFlag == 1) then
	set msg = "Error while accessing key file $PWD/mumps.key: No data"
else if (!(-r mumps.key)) then
	set msg = "Encryption key file $PWD/mumps.key not accessible"
else if ($invalidSymkeyFlag == 1) then
	set msg = "Error while accessing key file $PWD/mumps.key: No data"
else if (!(-e $GNUPGHOME/pubring.kbx)) then
	set msg = "Error while accessing key file $PWD/mumps.key: No secret key"
else if (!(-r $GNUPGHOME/pubring.kbx)) then
	set msg = "Encryption key file $PWD/mumps.key not accessible"
else
	@ fail = 0
	if ($invalidKeyringFlag == 1) then
		@ fail = 1
	else if (!(-e $GNUPGHOME/pubring.gpg) || !(-e $GNUPGHOME/secring.gpg)) then
		if (!(-e $GNUPGHOME/pubring.kbx) || !(-s $GNUPGHOME/pubring.kbx) || !(-r $GNUPGHOME/pubring.kbx)) then
			@ fail = 2
		endif
	else if (!(-s $GNUPGHOME/secring.gpg) || !(-r $GNUPGHOME/secring.gpg)) then
		@ fail = 3
	endif

	echo "fail is $fail" >> debughelp.txt
	ls -l $GNUPGHOME >>&! debughelp.txt

	if (0 != $fail) then
		set msg = "Error while accessing key file $PWD/mumps.key: No secret key"
	endif
endif

# Puts the expected output in the output file
echo $msg > $outfile
