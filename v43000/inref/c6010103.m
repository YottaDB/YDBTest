c6010103        ; ; ; problem with NEW indirection and "transcendental" frames
        ;
	Write "c6010103 beginning",!
        n (act)
        i '$d(act) n act s act="zp @$zpos"
        s cnt=0
        s cid=123
        s x="cid"
        n @x
        s cid=456
        i $g(cid)'=456 s cnt=cnt+1 x act
        zb lab0:"i $g(cid)'=456 s cnt=cnt+1 x act"
        zb lab2:"i $g(cid)'=456 s cnt=cnt+1 x act"
lab0    d lab1
        i $g(cid)'=456 s cnt=cnt+1 x act
        w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
        q
lab1    i $g(cid)'=456 s cnt=cnt+1 x act
        x "i $g(cid)'=456 s cnt=cnt+1 x act"
lab2    q
