#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# A MUPIP JOURNAL command that does a SHOW (=ALL, =BROKEN etc.) on multiple regions could display the output
# for the multiple regions in an arbitrary order depending on the env var "gtm_mupjnl_parallel" and arbitrary
# assignments of regions to individual processes. To keep test output deterministic this is a helper awk program
# that sorts the output based on the journal name being showed.
# Note that we use two-dimensional arrays here but do it as out[file, cnt] (instead of out[file][cnt]) as the
# latter syntax is not accepted by gawk 3.x but works in gawk 4.x. The former syntax works in gawk 3.x and 4.x.
BEGIN	{ file = ""; }
	{
		if ($1 == "SHOW")
		{
			if (file != "")
				cntarr[file] = cnt;
			file = $NF;
			cnt = 0;
			files[file] = ""
		}
		if ($1 ~ /%YDB-.*/)
		{
			if (file != "")
			{
				out[file, cnt++] = "";
				out[file, cnt++] = out[file, 1];
				cntarr[file] = cnt;
			}
			n = asorti(files);
			for (k = 1; k <= n; k++)
			{
				file = files[k];
				cnt = cntarr[file];
				for (i = 0; i < cnt; i++)
				{	# There are 3 blank lines after each journal file's show output except
					# the last one where only 2 blank lines exist. So suppress one blank line
					# of the last file. In addition, there is a '------..' line just before
					# the "SHOW output" line of the next journal file which is included in
					# the current journal file's "out" array. Filter that out too for the last file.
					# In summary, filter out the last 2 lines of the last file.
					if ((k != n) || (i < (cnt - 2)))
						print out[file, i];
				}
			}
			file = "";
			cnt = 0;
		}
		if (file == "")
		{
			print $0;
			next;
		} else
			out[file, cnt++] = $0;
	}
END	{}
