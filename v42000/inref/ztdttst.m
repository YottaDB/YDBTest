ztdttst ; ; ;
        ;
        New (act)
        If '$Data(act) New act Set act="W !,$ZPOS,! ZP @$ZPOS W !"
        Set cnt=0
        If 0
        Set:$Test cnt=cnt+1 Xecute:$Test act
        New $ZTrap
        Set $ZTRAP="S:$T cnt=cnt+1 S var=1"
        Kill var
        Set x=var
sb0     Xecute:$Test act
        If 1
        Set:'$Test cnt=cnt+1 Xecute:'$Test act
        Set $ZTRAP="S:'$T cnt=cnt+1 S var=1"
        Kill var
        Set x=var
sb1     Xecute:'$Test act
        Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)
        Quit

