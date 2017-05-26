tp_ztp	;
	tflag=\$r(3)    ; this way we will have a test for ZT too
	tflag=\$r(2)
	if tflag=1 ts
	if tflag=2 zts
	if $r(2)=1 s ^apini($cnt)=$j
	if $r(2)=1 s ^bpini($cnt)=$j
	if $r(2)=1 s ^cpini($cnt)=$j
	if $r(2)=1 s ^dpini($cnt)=$j
	if $r(2)=1 s ^epini($cnt)=$j
	if $r(2)=1 s ^fpini($cnt)=$j
	if $r(2)=1 s ^gpini($cnt)=$j
	if $r(2)=1 s ^hpini($cnt)=$j
	if tflag=1 tc
	if tflag=2 ztc
	q

