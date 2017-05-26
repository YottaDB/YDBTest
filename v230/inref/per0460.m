per0460	;per0460 - test of job command
	;
	s c=0
	s jobarg="^per0460a:(nodet:pro=""PER0460A"":im="""_$zdir_"per0460a.exe"")"
	j @jobarg
	w !,"jobbed per0460a"
	s mbx="jobmbx" o mbx:tmpmbx u mbx h 10
	r:10 p u "" i '$t s c=c+1 w !,"no answer from jobbed process"
	c mbx
	i 'c w !,"read ",p," from jobbed process"
	w !,$s(c:"BAD result",1:"OK")," from simple test of Job"
	q
