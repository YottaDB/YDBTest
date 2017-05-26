#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# works with -detail and -nodetail extract output
"" != $0 {
	if ($0 ~ /^GDS/)
		next
	rectype = $1
	gsub(/[ ]*/,"",rectype)
	if ("EPOCH" == rectype)
		next	# do not count EPOCHs
	if (0 == (rectype in tot))
		rec[++recs]=rectype
	tot[rectype]++
	if (("05" == rectype) || (rectype ~ /SET/))
	{
		globali = $NF;
		gsub(/\=.*/,"",globali)
		gsub(/\(.*/,"",globali)
		if (0 == (globali in sets))
			global[++gbls]=globali
		sets[globali]++
	}
	if (("04" == rectype) || ("10" == rectype) || (rectype ~ /KIL/))
	{
		globali = $NF;
		gsub(/\(.*/,"",globali)
		if (0 == (globali in kills))
			globalk[++gblsk]=globali
		kills[globali]++
	}
}
END {
	if (1 == ENVIRON["extract_summary_sort"])
	{
		sort = 1;
		sortstr = "in sorted order"
	} else
	{
		sort = 0;
		sortstr = "in the order of appearance"
	}
	printf "#Number of records of type (%s):\n", sortstr;
	if (sort)
		asort(rec);
	for (i = 1; i <= recs; i++)
		print rec[i] "\t" tot[rec[i]];
	if (gbls)
	{
		printf "#Globals set (%s):\n", sortstr;
		if (sort)
			asort(global);
		for (i = 1; i <= gbls ; i++)
			print global[i] "\t" sets[global[i]];
	}
	if (gblsk)
	{
		printf "#Globals (z)killed (%s):\n", sortstr;
		if (sort)
			asort(globalk);
		for (i = 1; i <= gblsk ; i++)
			print globalk[i] "\t" kills[globalk[i]];
	}
}
