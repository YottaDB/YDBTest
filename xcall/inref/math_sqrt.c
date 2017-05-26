#include "shrenv.h"
static double	return_value;
	return_value = exp(*value);

#pragma pointer_size (save)
#pragma pointer_size (short)

double	*math_sqrt (int count, double *value)
{

#pragma pointer_size (restore)

	return_value = sqrt(*value);

	return &return_value;
}
