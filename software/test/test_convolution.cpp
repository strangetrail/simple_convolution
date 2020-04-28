#include <math.h>
#include <time.h>
#include "system.h"
#include "io.h"

int main()
{
  int idx1, idx2,
      data [32][4];
  for (idx1 = 0; idx1 < 4; idx1++)
	  for (idx2 = 0; idx2 < 32; idx2++)
	  {
//  data[idx1][idx2] = idx1 + idx2;
		  srand(time(NULL));
		  data[idx1][idx2] = rand();
	  }
  IOWR(TEST_0_BASE, 0, (int)((int *)data));
  IOWR(TEST_0_BASE, 1, (int)((int *)(data + 3 * 32)));
  return 0;
}
