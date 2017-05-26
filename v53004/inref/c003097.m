c003097	;
	set $ZTRAP="do error"
	set mainlvl=$ZLEVEL
	for i=1:1:10000 do
	. do badopen
	use $PRINCIPAL write $select($get(errcnt):"FAIL",1:"PASS")," from ",$T(+0),!
	quit
error	;
	; go back to the loop and try the open again if it's an	ERR_RMWIDTHPOS
	if $zs'["RMWIDTHPOS",$incr(errcnt) u $p w "***** ",i," *****",!,$zstatus,! zgoto 1
	;if 150375962'=$PIECE($zstatus,",",1) u $p w "***** ",i," *****",!,$zstatus,! zgoto 1
	zgoto mainlvl
	quit
badopen	;
	open "file":RECORDSIZE=0
	q
