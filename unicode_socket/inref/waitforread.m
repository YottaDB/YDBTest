waitforread(whichreads,maxtime);
	set h1=$h,read=0,timedout=0,done=0,j=0
	View "NOUNDEF"
        f  quit:(read=1)!(done=1)!(timedout=1)  do
        .       set j=j+1
	.	if (whichreads="last") do
        .       .	if ((^dataread(4)=1)&(^dataread(5)=1)) s read=1
	.	else  if (whichreads="all") do
	.	.	if ($d(^client2done)) s done=1
        .       if (j#100=0) do
        .       .       set h2=$h
        .       .       set dif=$$^difftime(h2,h1)
        .       .       if dif>maxtime set timedout=1
	View "UNDEF"
	if (timedout=1)&(whichreads="last") w "Client did not end reading the data after 30 sec"
	if (timedout=1)&(whichreads="all") w "Client did not exit after "_maxtime_" sec at: "_$h
	q
