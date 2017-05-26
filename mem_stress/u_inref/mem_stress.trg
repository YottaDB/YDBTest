; A minor trigger configuration for some globals used by mem_stress.m
;
+^afill(subs=:) -commands=SET -xecute="set ^cfill(subs)=$ztval"
; 10% of the time, do a trestart to ensure that trestarts work fine inside triggers 
+^cfill(subs=:) -commands=SET -xecute="if (($trestart=0)&($random(10)=1))  trestart"
