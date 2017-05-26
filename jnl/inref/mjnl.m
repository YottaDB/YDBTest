	Set output="mjnl.mjo0",error="mjnl.mje0"
     Open output:newversion,error:newversion
     Use output
     W "PID: ",$J
     Close output
	;
	Set unix=$zv'["VMS"
	For I=1:1:4 do
	. If unix J @("in^jswitch(""set""):(output=""jswitch.mjo"_I_""":error=""jswitch.mje"_I_""")")
	. e  J @("in^jswitch(""set""):(detached:startup=""startup.com"":output=""jswitch.mjo"_I_""":error=""jswitch.mje"_I_""")")
	;
	Quit
