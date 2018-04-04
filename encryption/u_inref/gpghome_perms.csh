#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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

# Verify that if the GNUPGHOME permissions are such that they are accessible ONLY for the current user (which is typical of a default
# GNUPG key generation), then encryption plugin should issue an appropriate error.

# Do a minimal setup
$gtm_tst/com/dbcreate.csh mumps

# Make a few updates
$GTM << EOF
f i=1:1:100 s ^a(i)=i
h
EOF

# Verify that we can access the globals
$GTM << EOF
w ^a(100)
h
EOF

chmod 700 $GNUPGHOME
chmod 600 $GNUPGHOME/*

# Verify that if another user tries to access the same global on an encrypted database without having the key encrypted with his
# public keys, the encryption plugin should appropriately issue an error
$gtm_tst/$tst/u_inref/user2.csh >&! user2.log

chmod -R 755 $GNUPGHOME

$gtm_tst/com/check_error_exist.csh remote_user.log "YDB-E-CRYPTINIT"
$gtm_tst/com/dbcheck.csh
