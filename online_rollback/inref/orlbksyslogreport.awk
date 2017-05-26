# match up all STARTs to CMPLTs and NOSTPs if directed to do so
# inputs:
#	td=<test directory> or ${PWD:h:h:t}
#	checknostop=1 - NOSTP isn't issued if nothing is rolled back
#	syslog file

# Split the SYSLOG messages at %% so that all we get is the GTM message
BEGIN {
	FS = "%%"
}

# explanations of AWK usage
# - grab the PID from the syslog line
#	currpid=gensub(/^.*GTM.*([0-9]+).*$/,"\\1","g",$1);
# - strip off trailing message data
#	sub(/--.*$/,"",$2);

/ORLBK(START)/ && $0 ~ td {
	currpid=gensub(/^.*GTM.*([0-9]+).*$/,"\\1","g",$1);
	if (length(debug)) {print "START:" currpid}
	sub(/--.*$/,"",$2);
	start[currpid]=start[currpid] $2
}

/ORLBK(CMPLT)/ && $0 ~ td {
	currpid=gensub(/^.*GTM.*([0-9]+).*$/,"\\1","g",$1);
	if (length(debug)) {print "CMPLT:" currpid ":" length(start[currpid])}
	sub(/--.*$/,"",$2);
	if (length(start[currpid])) {
		sub(/--.*$/,"",$2);
		complete[currpid]=complete[currpid] $2 "\n"
		if (length(debug)) {print "CMPLT:" currpid ":" complete[currpid]} 
	}
}

/ORLBKNOSTP/ {
	currpid=gensub(/^.*GTM.*([0-9]+).*$/,"\\1","g",$1);
	if (length(debug)) {print "NOSTP:" currpid ":" length(start[currpid])}
	if (length(start[currpid])) {
		sub(/--.*$/,"",$2);
		nostop[currpid]=nostop[currpid] $2 "\n"
		if (length(debug)) {print "NOSTP:" currpid ":" nostop[currpid]} 
	}
}

END {
	for(pid in start) {
		if (0 == length(start[pid])) { continue }
		if ("" == nostop[pid] && length(checknostop)) {
			print "TEST-I-INFO : ORLBKNOSTP not seen in syslog for pid " pid
		}
		if ("" == complete[pid]) {
			print "TEST-F-FAIL : ORLBKCMPLT not seen in syslog for pid " pid complete[pid]
		}
	}
	print "online rollback syslog report complete"
}
