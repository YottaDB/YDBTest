#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE513737 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE513737)

GT.M returns the correct value for a Boolean expression containing a subscripted local variable when that variable is affected by side-effects later in the expression and gtm_boolean>=1. Previously, GT.M evaluated the boolean using the value of the subscripted local after all side-effects. This issue did not affect unsubscripted local variables or globals of any kind. (GTM-DE513737)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"

echo "# In each of the below tests, run a routine [gtmde513737] that contains a boolean expression that:"
echo "# 1. Contains a subscripted local variable"
echo "# 2. Contains code that modifies that subscripted local variable via a side effect"
echo "# 3. References that subscripted variable before the code that induces the side effect"
echo "#"
echo '# Run the routine also with each valid value of $gtm_boolean (0-3), then the first invalid value (4).'
echo "# This range is based on the definition of 'gtm_bool_type' in 'sr_port/fullbool.h',"
echo "# since it is values from this enum that are expected and referenced when 'gtm_boolean' is read"
echo "# from the environment during mumps process startup in 'sr_port/gtm_env_init.c'."

echo "# Test 1: gtm_boolean = 1"
echo "# Set gtm_boolean = 1"
setenv gtm_boolean 1
echo "# Run the [gtmde513737] routine"
$gtm_dist/mumps -r gtmde513737
rm *.o

echo "# Test 2: gtm_boolean = 2"
echo "# Set gtm_boolean = 2"
setenv gtm_boolean 2
echo "# Run the [gtmde513737] routine"
$gtm_dist/mumps -r gtmde513737
rm *.o

echo "# Test 3: gtm_boolean = 3"
echo "# Set gtm_boolean = 3"
setenv gtm_boolean 3
echo "# Run the [gtmde513737] routine"
$gtm_dist/mumps -r gtmde513737
rm *.o

echo "# Test 4: gtm_boolean = 0"
echo "# Set gtm_boolean = 0"
setenv gtm_boolean 0
echo "# Run the [gtmde513737] routine"
$gtm_dist/mumps -r gtmde513737
