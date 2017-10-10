#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#include "hashtable.h"

static Hashtable ht;

static uint32_t factor2x(uint32_t bkt_count)
{
	return bkt_count == 0x80000000 ? bkt_count : bkt_count << 1;
}
static void test(uint64_t k)
{
	uint32_t entry = (*ht->get_entry)(ht, k);
	fprintf(stderr, "DEBUG: get %zd -> entry %u, value %i\n", k, entry, (*ht->get_value)(ht, entry));
}
int main(void)
{
	if (!(ht = ht_init(5, &factor2x))) {
		fprintf(stderr, "ERROR: failed in ht_init\n");
		return 1;
	}
	(*ht->put)(ht, 33, 35);
	(*ht->put)(ht, 33, 36);
	(*ht->put)(ht, 34, 37);
	test(33);test(34);test(35);
	return 0;
}
