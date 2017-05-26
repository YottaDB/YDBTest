dsecache;
	; this assumes an 8 region database layout
	;
start	;
        set ^stop=0
	set numjobs=4
        set jmaxwait=0    ; signals d ^job() to job off processes and return right away without waiting
        do ^job("tpntpupd",numjobs,"""""")	; start 4 background processes that do ^tpntpupd
	quit
waitbeg	;
	set numjobs=4
	set waitreplic=1	; signal waitchrg to wait for numjobs+1 if replication servers are active
	set status=$$^waitchrg(-numjobs,200,"*") ; wait for all background processes to have accessed all regions
	; wait for 200 seconds above for all processes to attach to all database regions.
	; the above is necessary or else the following DSE (done in dse_cache.csh/com) will give FTOK conflict message at startup
	quit
stop	;
	set ^stop=1       ; signals all jobbed of processes running tpntpupd.m to stop
	do wait^job	; waits for all jobbed of processes to die
	quit
