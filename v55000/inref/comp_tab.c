#include <stdio.h>
#include "mdef.h"
#include "gdsroot.h"
#include "gdsbt.h"
#include "gdsfhead.h"
#include "jnl_get_checksum.h"

#define LITTLE  	0
#define BIG		1
#define SLICE_BY	4
#define TABLE_SIZE	256

#define TOPBIT (1L << 31) 
#define	BITMASK(X) (1L << (X))

uint4 reflect (uint4 num, int len);
int endianness(void);
void gentab(void);
void table_swap(void);
void disptab(void);

const uint4 Poly = 0x1EDC6F41;
uint4 csum_table_test[SLICE_BY][TABLE_SIZE];
int main()
{
	gentab();
	if(endianness())
		table_swap();
	/*disptab();*/
	if(memcmp((const void *)csum_table_test, (const void *)csum_table, SLICE_BY*TABLE_SIZE))
		printf("TABLE-MISMATCH: Generated table and defined table are not identical\n");	
	else
		printf("TABLE-MATCH: Generated table and defined table are identical\n");	
	return 0;
}

/* This function is used for the reflection len bits from right in the byte representation of input num */
uint4 reflect (uint4 num, int len)
{
	int   i;
	uint4 tmp = num;
	for (i=0; i<len; i++)
	{
		if (tmp & 1L) 				/*if bit is turned on at i'th position from right in the bit representation of input number*/
			num |=  BITMASK((len-1)-i);  	/*the i'th bit from left in reflected number should be turned on */
		else					/*if bit is turned off at i'th position from right in the bit representation of input number*/
			num &= ~BITMASK((len-1)-i);	/*the i'th bit from left in reflected number should be turned off */
		tmp >>= 1;
	}
	return num;
}

/*If little returns 0 else return 1*/
int endianness()
{
	uint4 num = 1;
	return ((1 == *((char *)&num)) ? LITTLE : BIG);
}

/* This function does byte-swap of the each table entry */
void table_swap()
{
        int i, j;
        for (j = 0; j < 4; j++)
                for (i = 0; i <= 0xFF; i++)
                {
			csum_table_test[j][i] =
			((csum_table_test[j][i] << 24) & 0xFF000000) |
			((csum_table_test[j][i] <<  8) & 0x00FF0000) |
			((csum_table_test[j][i] >>  8) & 0x0000FF00) |
			((csum_table_test[j][i] >> 24) & 0x000000FF);	
                }
	return;
}

/* This function generates 4 tables for checksum calculations by slicing-by-4 algorithm */
void gentab()
{
	uint4 i,j,k=0;
	uint4 checksum;
	
	for (i = 1; i <= 0xFF; i++) 
	{
		checksum = reflect(i,32);
		for (j=0; j<8; j++)
			checksum = (checksum & TOPBIT) ? (checksum << 1) ^ Poly : checksum << 1;
		csum_table_test[0][i] = reflect(checksum, 32); 
	} 
	
	for (i = 0; i <= 0xFF; i++) 
	{ /* for Slicing-by-4  */
		csum_table_test[1][i] = (csum_table_test[0][i] >> 8) ^ csum_table_test[0][csum_table_test[0][i] & 0xFF]; 
		csum_table_test[2][i] = (csum_table_test[1][i] >> 8) ^ csum_table_test[0][csum_table_test[1][i] & 0xFF]; 
		csum_table_test[3][i] = (csum_table_test[2][i] >> 8) ^ csum_table_test[0][csum_table_test[2][i] & 0xFF]; 
	}
	return;
}

void disptab()
{
	int i, j, k=0;
	for (j = 0; j < 4; j++)
	{
		printf("\n\nTABLE=%u\n\n",j);
		for (i = 0; i <= 0xFF; i++)
		{
			if(k<8)
			{
				printf("0x%x, ",csum_table_test[j][i]);
				k++;
			}
			else
			{
				printf("\n0x%x, ",csum_table_test[j][i]);
				k=1;
			}
		}
		printf("\n");
	}
	return;
}
