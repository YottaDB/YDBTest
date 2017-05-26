{
if(/Write critical section owner is process id/) {$NF="XDSE_PIDX"}
if(/process id:/) {$4="XDSE_PIDX"}
if(/Cache freeze id/ && $4 != "0x00000000") {$(NF - 3)="XXXXXXXX"}
if(/In critical section/ && $4 != "0x00000000") {$4="XDSE_PIDX"}
{print}
}
