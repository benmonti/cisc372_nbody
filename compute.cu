#include <stdlib.h>
#include <math.h>
#include "vector.h"
#include "config.h"
#include <cuda_runtime.h>

// compute: Updates the positions and locations of the objects in the system based on gravity.
// Parameters: None
// Returns: None
// Side Effect: Modifies the hPos and hVel arrays with the new positions and accelerations after 1 INTERVAL
__global__ void compute(vector3 *d_hPos, vector3 *d_hVel, double *d_mass)
{
	// make an acceleration matrix which is NUMENTITIES squared in size;

	int i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i >= NUMENTITIES)
		return;
	vector3 accel_sum = {0, 0, 0};
	int k;
	// first compute the pairwise accelerations.  Effect is on the first argument.
	for (int j = 0; j < NUMENTITIES; j++)
	{
		if (i != j)
		{
			vector3 distance;
			for (k = 0; k < 3; k++)
				distance[k] = d_hPos[i][k] - d_hPos[j][k];
			double magnitude_sq = distance[0] * distance[0] + distance[1] * distance[1] + distance[2] * distance[2];
			if (magnitude_sq < 1e-12)
				continue;
			double magnitude = sqrt(magnitude_sq);
			double accelmag = -1 * GRAV_CONSTANT * d_mass[j] / magnitude_sq;

			accel_sum[0] += accelmag * distance[0] / magnitude;
			accel_sum[1] += accelmag * distance[1] / magnitude;
			accel_sum[2] += accelmag * distance[2] / magnitude;
		}
	}

	// sum up the rows of our matrix to get effect on each entity, then update velocity and position.
	// compute the new velocity based on the acceleration and time interval
	// compute the new position based on the velocity and time interval
	for (k = 0; k < 3; k++)
	{
		d_hVel[i][k] += accel_sum[k] * INTERVAL;
		d_hPos[i][k] += d_hVel[i][k] * INTERVAL;
	}
}
