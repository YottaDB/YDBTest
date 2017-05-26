#include "shrenv.h"
double	return_value;

#pragma pointer_size (save)
#pragma pointer_size (short)

double	*math_exp (int count, double *value)
{

#pragma pointer_size (restore)

	return_value = exp(*value);

	return &return_value;
}
