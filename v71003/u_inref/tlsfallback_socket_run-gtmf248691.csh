#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper for tlsfallback_socket-gtmf248691. Drives one client/server SOCKET device TLS connection and
# collects the outcome reported by both sides into outcome_<tag>.out.
#
# $1 - tag naming this run, used in the output file names
#
# Variable names are prefixed so that sourcing this does not disturb the caller's variables.

set tfs_tag = $1

$ydb_dist/mumps -run gtmf248691sock $portno >&! server_${tfs_tag}.out
if (-e gtmf248691sockclient.txt) mv gtmf248691sockclient.txt client_${tfs_tag}.out
if (-e gtmf248691sockclient.err) mv gtmf248691sockclient.err client_${tfs_tag}.err
cat server_${tfs_tag}.out client_${tfs_tag}.out >&! outcome_${tfs_tag}.out
unset tfs_tag
