template -segment -mutex_slots=2048
rename -segment DEFAULT ABCD
show -segment
show -template
show -commands -file=chtemplate.com
