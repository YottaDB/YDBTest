init(timeout,longwait)	;
	SET ^timeout=timeout
	SET ^longwait=longwait
	SET ^delta=6
	SET $ztrap="s tendtp=$h d ^ztrapit  halt"
	SET $zmaxtptime=timeout
	q
	;
ERROR   SET $ZT=""
	W !,"ZSHOW ""*""",!
	ZSHOW "*"
        ZM +$ZS
	if $tlevel trollback
	Q
