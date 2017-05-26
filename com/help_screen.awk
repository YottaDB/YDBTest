BEGIN {tab="\t"}
/##HELP_SCREEN_PROLOGUE/	{ tab = ""}
$1 ~ /##HELP_SCREEN/ {
	if (skip_line==1)
		printf ":\n";
	printf tab
	for (i=2;i<=NF;i++)
		printf $i " ";
	printf "\n";
	skip_line=0
}
$1 ~ /case/ {
	if (skip_line==0) 
		printf "\n"; 
	else 
		printf ", "
	gsub(/"/,"",$2);
	gsub(/:/,"",$2);
	printf $2; 
	skip_line=1
}
