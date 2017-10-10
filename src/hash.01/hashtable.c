#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "hashtable.h"

#define ERR_VAL 0xFFFFFFFF


static int32_t hash(uint64_t key)
{
	return (uint32_t)(key ^ (key >> 32));
}
static uint32_t bucket_for(uint64_t key, uint32_t cap)
{
	return (uint32_t)(hash(key) & (cap - 1));
}
static void rehash(Hashtable ht)
{
	return;
}
static uint32_t intern(Hashtable ht, int64_t key)
{
	uint32_t bkt = bucket_for(key, ht->bkt_cap);
	for (uint32_t i = ht->bkts[bkt] ; ERR_VAL != i ; i = ht->next[i]) {
		if (ht->keys[i] == key)
			return i;
	}
	if (ht->size >= ht->key_cap) {
		rehash(ht);
		bkt = bucket_for(key, ht->bkt_cap);
	}
	uint32_t entry;
	if (-1 != ht->first_free) {
		entry = ht->first_free; // TODO reassign first_free
	}
	else {
		entry = ht->next_unused++;
	}
	ht->next[entry] = ht->bkts[bkt];
	ht->bkts[bkt] = entry;
	ht->keys[entry] = key;
	ht->size++;
	return entry;
}
static uint32_t ht_put(Hashtable ht, int64_t key, int32_t val)
{
	uint32_t entry = intern(ht, key);
	ht->vals[entry] = val;
	return entry;
}
static uint32_t ht_get_entry(Hashtable ht, int64_t key)
{
	uint32_t bkt = bucket_for(key, ht->bkt_cap);
	for (uint32_t i = ht->bkts[bkt] ; ERR_VAL != i ; i = ht->next[i]) {
		if (ht->keys[i] == key)
			return i;
	}
	return ERR_VAL;
}
static int32_t ht_get_value(Hashtable ht, uint32_t entry)
{
	if (entry == ERR_VAL || ht->key_cap < entry)
		return 0x80000000;
	return ht->vals[entry];
}

Hashtable ht_init(unsigned sz_exponent, uint32_t (*load_factor)(uint32_t))
{
	Hashtable ht;
	if (sz_exponent > 24) {
		fprintf(stderr, "ERROR: size too big: %u\n", sz_exponent);
		goto err0;
	}
	if (!(ht = malloc(sizeof(*ht)))) {
		fprintf(stderr, "ERROR: malloc failed\n");
		goto err0;
	}
	const uint32_t bkt_cap = 1 << sz_exponent;
	const uint32_t key_cap = (*load_factor)(bkt_cap);
	if (!(ht->keys = malloc(sizeof(*ht->keys) * key_cap))) goto err1;
	if (!(ht->vals = malloc(sizeof(*ht->vals) * key_cap))) goto err2;
	if (!(ht->bkts = malloc(sizeof(*ht->bkts) * bkt_cap))) goto err3;
	if (!(ht->next = malloc(sizeof(*ht->next) * key_cap))) goto err4;
	memset(ht->keys, 0, sizeof(*ht->keys) * key_cap);
	memset(ht->next, 0, sizeof(*ht->next) * key_cap);
	memset(ht->bkts, -1, sizeof(*ht->bkts) * bkt_cap);
	ht->bkt_cap     = bkt_cap;
	ht->key_cap     = key_cap;
	ht->size        = 0;
	ht->first_free  = -1;
	ht->next_unused = 0;
	ht->put         = ht_put;
	ht->get_entry   = ht_get_entry;
	ht->get_value   = ht_get_value;
	ht->load_factor = load_factor;
	return ht;
err4:
	free(ht->bkts);
err3:
	free(ht->vals);
err2:
	free(ht->keys);
err1:
	free(ht);
err0:
	return NULL;
}
