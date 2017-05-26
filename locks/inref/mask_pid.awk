/PID/ {
	pid=$0;
	gsub(/.*PID= /,"",pid)
	gsub(/ .*/,"",pid)
	if (0==(pid in pids))
		pids[pid]="PID"++count
	gsub(pid,pids[pid],$0)
}
{print}
