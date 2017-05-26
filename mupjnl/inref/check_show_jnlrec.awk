($2 ~ /[0-9][0-9]*/) && ($1 !~ /EPOCH|PBLK/) {
	gsub("KIL[ 	]","KILL ");	# To make output same as extract output, (fill ZKIL to ZKILL, etc.)
	tot[$1]=$2;print; 
}
END {
	TOT_KILL = tot["KILL"] + tot["FKILL"] + tot["GKILL"] + tot["TKILL"] + tot["UKILL"]
	TOT_ZKILL = tot["ZKILL"] + tot["FZKILL"] + tot["GZKILL"] + tot["TZKILL"] + tot["UZKILL"]
	TOT_SET = tot["SET"] + tot["FSET"] + tot["GSET"] + tot["TSET"] + tot["USET"]
	print "   TOT_KILL   " TOT_KILL
	print "   TOT_ZKILL  " TOT_ZKILL
	print "   TOT_SET    " TOT_SET
	for (i in tot)
		TOTAL += tot[i]
	print "   TOTAL      " TOTAL
}

