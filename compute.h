#ifndef COMPUTE_H
#define COMPUTE_H

#include "vector.h"

__global__ void compute(vector3 *d_hPos, vector3 *d_hVel, double *d_mass);

#endif
