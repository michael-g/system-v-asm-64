#ifndef mg_hashtable_01_h
#define mg_hashtable_01_h

#include <stdint.h>


struct struct_hashtable {
	int64_t *keys;
	int32_t *vals, first_free;
	uint32_t *bkts, *next, bkt_cap, key_cap, size, next_unused;
	uint32_t (*put)(struct struct_hashtable*, int64_t, int32_t);
	uint32_t (*get_entry)(struct struct_hashtable*, int64_t);
	int32_t (*get_value)(struct struct_hashtable*, uint32_t);
	uint32_t (*load_factor)(uint32_t);
};

typedef struct struct_hashtable *Hashtable;

Hashtable ht_init(unsigned sz_exponent, uint32_t (*load_factor)(uint32_t));

#endif
