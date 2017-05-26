initdat;Randomization Data for Prime field's primitive roots
lsmall; 
	SET ^prime=53
	SET ^root(1)=2 
	SET ^root(2)=3 
	SET ^root(3)=5 
	SET ^root(4)=8 
	SET ^root(5)=12 
	SET ^root(6)=14 
	SET ^root(7)=18 
	SET ^root(8)=19 
	SET ^root(9)=20 
	SET ^root(10)=21 
	q
lmid; 
	SET ^prime=101
	SET ^root(1)=11 
	SET ^root(2)=12 
	SET ^root(3)=15 
	SET ^root(4)=18 
	SET ^root(5)=26 
	SET ^root(6)=27 
	SET ^root(7)=28 
	SET ^root(8)=29 
	SET ^root(9)=34 
	SET ^root(10)=35 
	q

lbig; 
	SET ^prime=503
	SET ^root(1)=20 
	SET ^root(2)=29 
	SET ^root(3)=30 
	SET ^root(4)=31 
	SET ^root(5)=34 
	SET ^root(6)=35 
	SET ^root(7)=37 
	SET ^root(8)=38 
	SET ^root(9)=40 
	SET ^root(10)=41 
	q
	
lhuge; 
	SET ^prime=1009
	SET ^root(1)=22 
	SET ^root(2)=26 
	SET ^root(3)=31 
	SET ^root(4)=33 
	SET ^root(5)=34 
	SET ^root(6)=38 
	SET ^root(7)=46 
	SET ^root(8)=51 
	SET ^root(9)=52 
	SET ^root(10)=53 
	q
	
;	mid for some mid range
;	huge for very big range
small
	SET ^prime=2503
	SET ^root(1)=203 
	SET ^root(2)=205 
	SET ^root(3)=208 
	SET ^root(4)=212 
	SET ^root(5)=217 
	SET ^root(6)=220 
	SET ^root(7)=221 
	SET ^root(8)=224 
	SET ^root(9)=226 
	SET ^root(10)=228 
	q

mid
	SET ^prime=5003
	SET ^root(1)=500 
	SET ^root(2)=502 
	SET ^root(3)=504 
	SET ^root(4)=505 
	SET ^root(5)=506 
	SET ^root(6)=508 
	SET ^root(7)=509 
	SET ^root(8)=510 
	SET ^root(9)=511 
	SET ^root(10)=512 
	q

big
	SET ^prime=8009
	SET ^root(1)=502 
	SET ^root(2)=506 
	SET ^root(3)=509 
	SET ^root(4)=510 
	SET ^root(5)=511 
	SET ^root(6)=515 
	SET ^root(7)=516 
	SET ^root(8)=518 
	SET ^root(9)=519 
	SET ^root(10)=524 
	q

huge
	SET ^prime=20011
	SET ^root(1)=131 
	SET ^root(2)=132 
	SET ^root(3)=138 
	SET ^root(4)=147 
	SET ^root(5)=148 
	SET ^root(6)=155 
	SET ^root(7)=157 
	SET ^root(8)=161 
	SET ^root(9)=162 
	SET ^root(10)=166 
	q

initcust(size);     
        new i
	set vms=$zv["VMS"
        for i=0:1:size DO
        . if vms SET ^cust(i,^instance)=i_"|"_$j_"|"_$r(size)_$$^genstr(i+1)_"|"_i
        . else  SET ^cust(i,^instance)=i_"|"_$j_"|"_$r(size)_$$^ugenstr(i+1)_"|"_i
        q


