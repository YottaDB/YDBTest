-*
; kill1 and some set.m
+^a2345678	-command=S      -xecute="set x=$c(94)_$ztvalue set @x=$ztva,$ztva=x "
+^a2345678	-command=K,ZK   -xecute="set x=$ztol k @x"
+^a2345678(1)	-command=S	-xecute="set x=$c(94)_$ztvalue set @x=$ztva,$ztva=x "
+^a2345678(1)	-command=K	-xecute="set x=$ztol k @x"
+^a2345678(1)	-command=ZK	-xecute="set x=$ztol zk @x"
+^a2345678(1,2)	-command=S	-xecute="set x=$c(94)_$ztvalue set @x=$ztva,$ztva=x "
+^a2345678(1,2)	-command=K	-xecute="set x=$ztol k @x"
+^a2345678(1,2)	-command=ZK	-xecute="set x=$ztol zk @x"
+^a2345678(1,2,3) -command=S	-xecute="set x=$c(94)_$ztvalue set @x=$ztva,$ztva=x "
+^a2345678(1,2,3) -command=K	-xecute="set x=$ztol k @x"
+^a2345678(1,2,3) -command=ZK	-xecute="set x=$ztol zk @x"

+^a234567890123456789012345678901	-command=S,K -xecute="set x=1"
+^a234567890123456789012345678901(1)	-command=K   -xecute="set x=1"
+^a234567890123456789012345678901(1,2)	-command=ZW  -xecute="set x=1"
+^a234567890123456789012345678901(1,2,3)	-command=ZK  -xecute="set x=1"

+^axx(1)    -command=S     -xecute="set ^bxx(1)=$ZTVAlue"
+^axx(1)    -command=K     -xecute="kill ^bxx(1)"
+^cxxx(2)   -command=S,K   -xecute="set:$ZTRI=""S"" ^bxxx(2)=$ZTVAlue zkill:$ZTRI=""ZK"" ^bxxx(2) kill:$ZTRI=""K"" ^bxxx(2)"
+^ax(1,1,t3=:) -command=K -xecute="if t3=2 kill ^ax(1,1,3)"
+^ax(1,2,2)  -command=K    -xecute="set x=1"
+^ax(1,2,3)  -command=K    -xecute="kill ^ax(1,2,2)"
+^ax(t1=:,t2=:) -command=S -xecute="set ^ax(""keep"",t1,t2)=$ztva"
+^r(1,2)     -command=S    -xecute="set $ztva=$ztva_""triggered"""

; putfail
+^PF(t1="A10":"A40") -delim=0 -command=S -xecute="set x=$c(94)_t1 set @x=$ztvaLUE"
+^PF(t1="A50";"A60") -delim=0 -command=S -xecute="set x=$c(94)_t1 set @x=$ztvaLUE"
+^PF -command=K -xecute="set x=1"

