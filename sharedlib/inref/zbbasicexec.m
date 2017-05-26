zbbasic;
	write $zpos,"$zlevel=",$zlevel,!
	new %ALongVariableForMultiLevelIndr,ALongVariableForMultiLevelIndr1,ALongVariableForMultiLevelIndr2,ALongVariableForMultiLevelIndr4
        new mindex
	set ^zbbasic=step set AA="ZBREAKAA" set @AA="Avariable" set expr="ZBMAIN=22" set @expr
	set zbbasic("zbasic")=step
	set %ALongVariableForMultiLevelIndr="ALongVariableForMultiLevelIndr1"
	set ALongVariableForMultiLevelIndr1="ALongVariableForMultiLevelIndr2"
	set ALongVariableForMultiLevelIndr2="ALongVariableForMultiLevelIndr3"
	set ALongVariableForMultiLevelIndr3="ALongVariableForMultiLevelIndr4"
	set ALongVariableForMultiLevelIndr4="ALongVariableForMultiLevelIndr5"
	set @@@@@%ALongVariableForMultiLevelIndr="@@@@@"
	set @@@%ALongVariableForMultiLevelIndr="@@@"
	set @"%myindir"="%myindir"
	quit
verify;
	do ^examine($get(ALongVariableForMultiLevelIndr5),"@@@@@","ALongVariableForMultiLevelIndr5")
	do ^examine($get(ALongVariableForMultiLevelIndr3),"@@@","ALongVariableForMultiLevelIndr3")
	do ^examine($get(%myindir),"%myindir","%myindir")
	do ^examine($get(zbbasic("zbasic")),step,"zbbasic(""zbasic"")")
	quit
