setenv(file,count)	;
	open file:read
	set unix=$ZVersion'["VMS"
	if unix set envfile=file_"_env.csh"
	if 'unix set envfile=count_"env.com"
	open envfile:new
	for  use file read line quit:$zeof  do
	. set line1=$$^%MPIECE(line," ","|")
	. set last=$zlength(line1,"|")
	. set env=$piece(line1,"|",1)
	. set val=$$FUNC^%HD($tr($piece(line1,"|",last),"x"))
	. if unix use envfile write "set ",env,"_",count,"=""",val,"""",!
	. if 'unix use envfile write env,"_",count," == """,val,"""",!
