<!---
.. ##############################################################
.. #								#
.. # Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
.. # All rights reserved.					#
.. #								#
.. #	 This document contains the intellectual property	#
.. #	 of its copyright holder(s), and is made available	#
.. #	 under a license.  If you do not know the terms of	#
.. #	 the license, please stop and do not read further.	#
.. #								#
.. ##############################################################
-->

How to run interestposting benchmark
------------------------------------
1. Install the below releases at the following locations on the current system,

   - `GT.M V7.1-002` : `/usr/local/lib/fis-gtm/V7.1-002_x86_64`
   - `YottaDB r2.02` : `/usr/library/R202/pro`
   - `YottaDB r2.04` : `/usr/library/R204/pro`
   - `GT.M V7.1-010` : `/usr/local/lib/fis-gtm/V7.1-010_x86_64`

2. Run the following in a `tcsh` shell. And note down the time taken for each version/job combination.
   And finally clean up all the test artifacts from the current directory.

   - cd YDBTest/benchmarks/interestposting
   - source interestposting.csh
   - git clean -f .

