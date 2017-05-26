+^ACCT      -commands=Set,Kill -xecute="set x=$increment(^fired($ZTNAme,$ZTRIGGEROP))"
+^ACCT(:,:) -commands=Set,Kill -xecute="set x=$increment(^fired($ZTNAme,$ZTRIGGEROP))"

+^CUST      -commands=Set,Kill -xecute="set x=$increment(^fired($ZTNAme,$ZTRIGGEROP))" -name=customerglobal
+^CUST(:,:) -commands=Set,Kill -xecute="set x=$increment(^fired($ZTNAme,$ZTRIGGEROP))" -name=customerdata
