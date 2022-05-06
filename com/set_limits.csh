#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# Database configuration parameters, specified in bytes.                                      #
###############################################################################################
set MIN_KEY_SIZE = 3
set MAX_KEY_SIZE = 1019
set DEF_KEY_SIZE = 64
set MIN_BLOCK_SIZE = 512
set MAX_BLOCK_SIZE = 65024
set DEF_BLOCK_SIZE = 1024
set MIN_RECORD_SIZE = 0
set MAX_RECORD_SIZE = 1048576
set DEF_RECORD_SIZE = 256
set MIN_GLOBAL_BUFFER_COUNT = 64
set MAX_GLOBAL_BUFFER_COUNT = 2147483647
set DEF_GLOBAL_BUFFER_COUNT = 1024
set BLOCK_HEADER_PADDING = 50
set KEY_SPAN_PADDING = 4

###############################################################################################
# Journaling configuration parameters, specified in 512-byte pages.                           #
###############################################################################################
set MIN_JOURNAL_ALIGN_SIZE = 4096
set MAX_JOURNAL_ALIGN_SIZE = 4194304
set DEF_JOURNAL_ALIGN_SIZE = 4096
# Journal buffer must hold at least one record value (2048) + record key (2) +
# two maximum IO blocks (256) + 1
set MIN_JOURNAL_BUFFER_SIZE = 2307
set MAX_JOURNAL_BUFFER_SIZE = 1048576
set DEF_JOURNAL_BUFFER_SIZE = 2312
# Journal autoswitch needs to be greater than or equal to allocation limit
set MIN_AUTOSWITCH_LIMIT = 16384
set MAX_AUTOSWITCH_LIMIT = 8388607
set DEF_AUTOSWITCH_LIMIT = 8386560
# Journal allocation needs to be less than or equal to autoswitch limit
set MIN_ALLOCATION_LIMIT = 2048
set MAX_ALLOCATION_LIMIT = 8388607
set DEF_ALLOCATION_LIMIT = 2048
