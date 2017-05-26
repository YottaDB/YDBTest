updates
	; Do sets to the database until told to stop
	; save the pid so the test can wait for the process to stop
	set uppid="updates_pid"
	open uppid
	use uppid
	write $job,!
	close uppid
	kill ^quit
	set cnt=0
	for  quit:$data(^quit)  do
	. set ^a(cnt)="abcdefghijklmnop"
	. set cnt=cnt+1
	write "cnt= ",cnt,!
	quit
