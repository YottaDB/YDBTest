JUSTREAD
	set a="test"
	open a:(comm="ps -ef | grep $user | grep justread | grep -v grep":readonly)::"pipe"
	use a
	for  read x quit:$zeof  use $p write "line= ",x,! use a
	close a
	quit
