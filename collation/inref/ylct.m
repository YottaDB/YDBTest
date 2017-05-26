; This is a helper M script for testing various local collation features used in ylct subtest.

setparmwithlcl
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set incrtrapPOST="write $zstatus,!"
	set a(1)=1
setparm
	view "YLCT":1:-1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:-1:1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":1:1:1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":0:-1:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:0:-1
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":-1:-1:0
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	view "YLCT":0:0:0
	write "Collation: "_$view("YLCT")_"; ncol: "_$view("YLCT","ncol")_"; nct: "_$view("YLCT","nct"),!
	if $$set^%LCLCOL(1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(1,1,1)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(,,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	if $$set^%LCLCOL(0,0,0)
	write "Collation: "_$$get^%LCLCOL_"; ncol: "_$$getncol^%LCLCOL_"; nct: "_$$getnct^%LCLCOL,!
	quit

sortsafter
	write "0]]8 = "_(0]]8),!
	write "1]]7 = "_(1]]7),!
	write """0""]]8 = "_("0"]]8),!
	write "0]]""8"" = "_(0]]"8"),!
	write """0""]]""8"" = "_("0"]]"8"),!
	write """0.0""]]8 = "_("0.0"]]8),!
	write "0]]""08"" = "_(0]]"08"),!
	write "0]]""00"" = "_(0]]"00"),!
	write """0""]]""00"" = "_("0"]]"00"),!
	write "0]]$char(0) = "_(0]]$char(0)),!
	write """a""]]5 = "_("a"]]5),!
	write """a""]]""8"" = "_("a"]]"8"),!
	write """a""]]""b"" = "_("a"]]"b"),!
	quit

sortsafterwithoutcol
	if $$set^%LCLCOL(0)
	do sortsafter
	quit

sortsafterwithcol
	if $$set^%LCLCOL(1)
	do sortsafter
	quit

sortsafterwithoutcolwithnct
	if $$set^%LCLCOL(0,,1)
	do sortsafter
	quit

sortsafterwithcolwithnct
	if $$set^%LCLCOL(1,,1)
	do sortsafter
	quit
