gtm7595

access(n,id)
	merge p=^perm(^randi(id))	; ^perm and ^randi are in DEFAULT region, which is not journaled.
					; Journal buffers won't be allocated till we access globals ^A..^F
	for k=1:1:n do
	.	set gbl="^"_$char($ascii("A")+p(k)-1)
	.	set val=0+$get(@gbl,0)
	.	if (val+1)'=id write "ERROR: incorrect value for "_gbl,! zwrite val,id,k,p halt
	.	set @gbl=$incr(val)_$justify(" ",^reclen(gbl)-10)
	quit
	
genperms(n,iters)
	new p,i,avail
	kill ^perm
	for j=1:1:n set avail(j)=1
	set i=0
	do fill(1)
	zwrite i
	for k=1:1:iters set ^randi(k)=1+$random(i)
	set ^reclen("^A")=800
	set ^reclen("^B")=1600
	set ^reclen("^C")=3200
	set ^reclen("^D")=800
	set ^reclen("^E")=1600
	set ^reclen("^F")=3200
	quit

fill(d)
	if d>n merge ^perm($incr(i))=p
	else  do
	.	new j
	.	for j=1:1:n if avail(j) do
	.	.	set avail(j)=0
	.	.	set p(d)=j do fill(d+1)
	.	.	set avail(j)=1
	quit

