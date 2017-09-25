#pragma once

#if defined(_MSC_VER) && _MSC_VER <= 1800
	// We are visual studio, the single worst compiler known to man. Versions <= 1800 aka 2015 do not support ALIGNOF, and do not seem to have a non standard extension. C++11 is called that because it has been out for 4 years. Microsoft's incremental release model is showing its weaknesses just as with IE and Windows itself.
	#include <type_traits>
	#define ALIGNOF(type) std::alignment_of<type>::value
#else
	#define ALIGNOF(type) alignof(type)
#endif

#ifdef JOSIAH_MAC
	#include "platform_mac.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
const int MYEOF = EOF;
#undef EOF

#include <stdint.h>
#include <string.h>

#ifndef JOSIAH_INTERNAL
	#define NDEBUG
#endif
#include <assert.h>
#include <typeinfo>

typedef int8_t int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

typedef uint8_t uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

typedef size_t memsize;

#define int int64


// Misc. helper macros.

#define COMPILER_ERROR(i) if(compiler.error_count > 0) { return i; }

#define PO2(x) ((x != 0) && !(x & (x - 1)))
#define XOR(a, b) (( !(a)) != ( !(b)))

#if __has_builtin(__builtin_unreachable)
	#define UNREACHABLE() assert(false), __builtin_unreachable()
#elif defined(_MSC_VER)
	#define UNREACHABLE() assert(false), __assume(false)
#else
	#define UNREACHABLE() assert(!"Unreachable code.")
#endif

#define TOKENPASTE_INTERNAL(x, y) x ## y
#define TOKENPASTE(x, y) TOKENPASTE_INTERNAL(x, y)

// Misc. helper functions

void copyMemory(const void *src, uint64 bytes, void *dest);
bool compareString(const char *a, const char *b);
char * allocAndCopyString(const char *string);
char * allocAndCopyString(const unsigned char *string);
uint64 getPadding(uint64 offset, uint64 alignment);

#if defined(COMMON_IMPL)
// My memcpy wrapper, I prefer arguments in src, dest order.
void copyMemory(const void *src, uint64 bytes, void *dest) {
	memcpy(dest, src, bytes);
}

bool compareString(const char *a, const char *b) {
	return strcmp(a, b) == 0;
}

char * allocAndCopyString(const char *string) {
	if(string == 0) {
		return 0;
	}

	char *data = (char *) malloc(strlen(string)+1);
	strcpy(data, string);
	return data;
}

char * allocAndCopyString(const unsigned char *string) {
	return allocAndCopyString((const char *) string);
}

uint64 getPadding(uint64 offset, uint64 alignment) {
	return ((-offset) & (alignment - 1));
}
#endif


// New type safe array definition

struct ArrayMetaData {
	uint64 size, reserved;
};
void * NarrayNew(uint64 type_size, uint64 reserved = 100, bool zero_mem = false, bool is_static = false);
void * NarrayMaybeGrow(ArrayMetaData *meta, uint64 by, uint64 type_size);

#if defined(COMMON_IMPL)


void * NarrayNew(uint64 type_size, uint64 reserved, bool zero_mem, bool is_static) {
	assert(reserved != 0);

	ArrayMetaData *meta = 0;
	if(zero_mem) {
		meta = (ArrayMetaData *) calloc(sizeof(ArrayMetaData) + (type_size * reserved), 1);
	}
	else {
		meta = (ArrayMetaData *) malloc(sizeof(ArrayMetaData) + (type_size * reserved));
	}

	meta->size = is_static ? reserved : 0;
	meta->reserved = reserved;

	assert(meta);
	return meta+1;
}

void * NarrayMaybeGrow(ArrayMetaData *meta, uint64 by, uint64 type_size) {
	if(meta->size + by > meta->reserved) {
		uint64 factor_growth = ((meta->reserved+1) / 2);
		meta->reserved += by + factor_growth;
		meta = (ArrayMetaData *) realloc(meta, (sizeof(ArrayMetaData)) + (meta->reserved * type_size));
	}

	assert(meta);
	return meta+1;
}
#endif

#define NARRAY_NEW(type, opt_args...) ((type *) (NarrayNew(sizeof(type), ##opt_args)))


#define NGET_ARRAY_META(array) (((ArrayMetaData *) (array))-1)

#define NARRAY_SIZE(array) (array ? NGET_ARRAY_META(array)->size : 0)
#define NARRAY_SIZE_WRITABLE(array) (NGET_ARRAY_META(array)->size)

#define NARRAYITEM_UNSAFE(array, i) (array)[(i)]

#ifdef JOSIAH_INTERNAL
	#define NARRAYITEM(array, i) (array)[(((i >= 0) && (i < NARRAY_SIZE(array))) ? (i) : (assert(!"Out of bounds array" && false), 0))]
#else
	#define NARRAYITEM(array, i) (array)[(i)]
#endif

// Decltype has weird semantics. Be careful when using this, and use the below if things error.
#define NARRAY_PUSH(array, item) ((array = (decltype(array)) (NarrayMaybeGrow( NGET_ARRAY_META(array), 1, sizeof(*(array)) ))), (array)[NARRAY_SIZE_WRITABLE(array)++] = item)
#define NARRAY_PUSH_TYPE(array, item, type) ((array = (type *) (NarrayMaybeGrow( NGET_ARRAY_META(array), 1, sizeof(*(array)) ))), (array)[NARRAY_SIZE_WRITABLE(array)++] = item)

#define NARRAY_REMOVE(array, num) (memmove(&NARRAYITEM_UNSAFE(array, num), &NARRAYITEM_UNSAFE(array, num+1), sizeof(*array) * ((&NARRAY_LAST(array)+1)-&NARRAYITEM_UNSAFE(array, num+1))), NARRAY_SIZE_WRITABLE(array)--)
#define NARRAY_REMOVE_LOOP(array, num, index) (NARRAY_REMOVE(array, num), index--)

#define NARRAY_FREE(array) (free((array) ? (void *) NGET_ARRAY_META(array) : (void *) (array)), array = 0)

#define NARRAY_FIRST(array) (NARRAYITEM(array, 0))
#define NARRAY_LAST(array) (NARRAYITEM(array, NARRAY_SIZE(array)-1))


// loops over a narray. index is the index of the current element, value is a pointer to the element at that index.
#define FOR(index, value, array) if(bool _temp_loop = true) \
									for(uint64 index = 0; _temp_loop;) \
										for(auto value = array; _temp_loop;) \
											for(_temp_loop = false; index < NARRAY_SIZE(array); ++index, value=&array[index])

#define FOR_FROM(index, from, value, array) if(bool _temp_loop = true) \
									for(uint64 index = from; _temp_loop;) \
										for(auto value = &array[from]; _temp_loop;) \
											for(_temp_loop = false; index < NARRAY_SIZE(array); ++index, value=&array[index])


// Dynamic char * compatible strings. Guarunteed to be null terminated.

char * NstringAppend(char *a, char *b);
char * NstringAppendReg(char *a, const char *b);
char * NstringCreate();
char * NstringCreate(uint64 size);
char * NstringCreate(const char *str);
char * NstringCreate(const char *str, uint64 length);
char * NstringCreateFromUnterminated(const char *str, uint64 length);
char * NstringPush(char *string, char c);

#if defined(COMMON_IMPL)

char * NstringAppend(char *a, char *b) {
	a = (char *) NarrayMaybeGrow(NGET_ARRAY_META(a), NARRAY_SIZE(b)+1, sizeof(char));

	copyMemory(b, NARRAY_SIZE(b)+1, (a + NARRAY_SIZE(a)));
	NARRAY_SIZE_WRITABLE(a) += NARRAY_SIZE_WRITABLE(b);

	return a;
}

char * NstringAppendReg(char *a, const char *b) {
	uint64 b_size = strlen(b);

	a = (char *) NarrayMaybeGrow(NGET_ARRAY_META(a), b_size+1, sizeof(char));

	copyMemory(b, b_size+1, (a + NARRAY_SIZE(a)));
	NARRAY_SIZE_WRITABLE(a) += b_size;

	return a;
}

char * NstringCreate() {
	char *string = NARRAY_NEW(char, 10);

	string[9] = '\0';
	// We don't use this line since arrays default to size 0.
	// --NARRAY_SIZE_WRITABLE(string);

	return string;
}

char * NstringCreate(uint64 size) {
	char *string = NARRAY_NEW(char, size+1);

	string[size] = '\0';
	// --NARRAY_SIZE_WRITABLE(string);

	return string;
}

char * NstringCreate(const char *str) {
	uint64 len = strlen(str);
	char *string = NARRAY_NEW(char, len+1);

	copyMemory((void *) str, len+1, string);

	NARRAY_SIZE_WRITABLE(string) += len;

	return string;
}

char * NstringCreate(const char *str, uint64 length) {
	char *string = NARRAY_NEW(char, length+1);

	copyMemory((void *) str, length+1, string);

	NARRAY_SIZE_WRITABLE(string) += length;

	return string;
}

char * NstringCreateFromUnterminated(const char *str, uint64 length) {
	char *string = NARRAY_NEW(char, length+1);
	NARRAYITEM(string, length) = '\0';

	copyMemory((void *) str, length, string);

	NARRAY_SIZE_WRITABLE(string) += length;

	return string;
}

char * NstringPush(char *string, char c) {
	NARRAY_PUSH(string, c);
	NARRAY_PUSH(string, '\0');
	--NARRAY_SIZE_WRITABLE(string);
	return string;
}

#endif

#define NSTRING_PUSH(string, c) (string = NstringPush(string, c))
#define NSTRING_APPEND(string, c) (string = NstringAppend(string, c))
#define NSTRING_APPEND_REG(string, c) (string = NstringAppendReg(string, c))


// Primitive to arbitrary type hash map

struct MapElement {
	uint64 dead : 1;
	uint64 hash : 63;
	void *key;
	// After the struct is the value of this item.
};

struct HashmapMetaData {
	uint64 filled;
	uint64 capacity;
	uint64 value_size;
	uint64 (*hash_function)(void *key);
	bool (*comparator)(void *a, void *b);
};

void * createHashmap(uint64 value_size, uint64 (*hash_function)(void *key),	bool (*comparator)(void *a, void *b), uint64 initial_capacity = 256);
void * insertHashmapItem(void *map, void *key, void *value);
void * getHashmapItem(void *map, void *key);

#define GET_HASH_META(map) (((HashmapMetaData *) (map))-1)

#define HASH_CREATE(value_type, hash_function, comparator, opt_args...) ((value_type *) createHashmap(sizeof(value_type), hash_function, comparator, ##opt_args))

#define HASH_GET(map, key, type) (*((type *)getHashmapItem(map, (void *)key)))
#define HASH_GET_SLOT(map, key, type) (((type *)getHashmapItem(map, (void *)key)))

#define HASH_INSERT(map, key, value, type) {type TOKENPASTE(__value__, __LINE__) = (value); (map = (decltype(map)) insertHashmapItem(map, (void *) key, &TOKENPASTE(__value__, __LINE__)));}

#define HASH_FREE(map) (free(GET_HASH_META(map)), map = 0);

#if defined(COMMON_IMPL)

void * createHashmap(uint64 value_size, uint64 (*hash_function)(void *key),	bool (*comparator)(void *a, void *b), uint64 initial_capacity) {
	HashmapMetaData *meta = (HashmapMetaData *) calloc(sizeof(HashmapMetaData) + (value_size+sizeof(MapElement)) * initial_capacity, 1);

	meta->capacity = initial_capacity;
	meta->filled = 0;
	meta->value_size = value_size;
	meta->comparator = comparator;
	meta->hash_function = hash_function;

	return meta+1;
}

void printHashmap(void *map) {
	HashmapMetaData *meta = GET_HASH_META(map);

	printf("Capacity:%llu Filled:%llu\n", meta->capacity, meta->filled);

	uint64 i = 0;
	MapElement *elem = (MapElement *) map;

	while(i < meta->capacity) {
		uint64 elem_probe_dist = (i + meta->capacity - ((elem->hash-1) % meta->capacity)) % meta->capacity;
		printf("%llu: dead:%llu hash: %llu probe distance:%llu\n", i, elem->dead, elem->hash, elem_probe_dist);

		i++;
		elem = (MapElement *) ((char *) map + (meta->value_size+sizeof(MapElement))*i);
	}
}

void * rebuildHashmap(void *map, uint64 new_capacity) {
	HashmapMetaData *meta = GET_HASH_META(map);

	HashmapMetaData *new_meta = (HashmapMetaData *) calloc(sizeof(HashmapMetaData) + (meta->value_size+sizeof(MapElement)) * new_capacity, 1);
	*new_meta = *meta;
	new_meta->capacity = new_capacity;
	new_meta->filled = 0;

	uint64 i = 0;

	MapElement *elem = (MapElement *) map;

	while(i < meta->capacity) {
		if(elem->hash != 0 && !elem->dead) {
			insertHashmapItem(new_meta+1, elem->key, elem+1);
		}

		i++;
		elem = (MapElement *) ((char *) map + (meta->value_size+sizeof(MapElement))*i);
	}

	free(meta);

	return new_meta+1;
}

void * insertHashmapItem(void *map, void *key, void *value) {
	HashmapMetaData *meta = GET_HASH_META(map);

	meta->filled++;

	if((double)meta->filled / (double)meta->capacity > 0.9) {
		// Grow hash map.
		map = rebuildHashmap(map, meta->capacity * 2);
		meta = GET_HASH_META(map);
		meta->filled++;
	}

	void *temp_value = alloca(meta->value_size);
	copyMemory(value, meta->value_size, temp_value);
	value = temp_value;

	uint64 hash = meta->hash_function(key);
	uint64 i = hash % meta->capacity;
	uint64 dist = 0;

	MapElement *elem = (MapElement *) ((char *)map + (meta->value_size+sizeof(MapElement))*i);

	while(true) {
		if(elem->hash == 0) {
			// Uninitialized slot.
			elem->hash = hash+1;
			elem->key = key;
			copyMemory(value, meta->value_size, elem+1);

			return map;
		}

		uint64 elem_probe_dist = (i + meta->capacity - ((elem->hash-1) % meta->capacity)) % meta->capacity;
		if(elem_probe_dist > dist) {
			if(elem->dead) {
				elem->dead = 0;
				elem->hash = hash+1;
				elem->key = key;
				copyMemory(value, meta->value_size, elem+1);
				return map;
			}

			uint64 temp_hash = elem->hash-1;
			void *temp_key = elem->key;
			void *temp_value = alloca(meta->value_size);
			elem->hash = hash+1;
			elem->key = key;
			copyMemory(elem+1, meta->value_size, temp_value);
			key = temp_key;
			hash = temp_hash;
			copyMemory(temp_value, meta->value_size, value);
			dist = elem_probe_dist;
		}

		i = (i+1) % meta->capacity;
		elem = (MapElement *) ((char *) map + (meta->value_size+sizeof(MapElement))*i);
		dist++;
	}
}

void * getHashmapItem(void *map, void *key) {
	HashmapMetaData *meta = GET_HASH_META(map);

	uint64 hash = meta->hash_function(key);
	uint64 i = hash % meta->capacity;
	uint64 dist = 0;

	MapElement *elem = (MapElement *) ((char *) map + (meta->value_size+sizeof(MapElement))*i);
	while(true) {
		if(elem->hash == 0) {
			return 0;
		}

		uint64 elem_probe_dist = (i + meta->capacity - ((elem->hash-1) % meta->capacity)) % meta->capacity;
		if(dist > elem_probe_dist) {
			return 0;
		}

		if(hash == elem->hash-1 && meta->comparator(key, elem->key)) {
			return elem+1;
		}

		i = (i+1) % meta->capacity;
		elem = (MapElement *) ((char *) map + (meta->value_size+sizeof(MapElement))*i);
		dist++;
	}
}

#endif


// Common hash functions

uint64 hashUInt64(void *k);
uint64 hashUInt32(void *k);
bool comparatorBitwise(void *a, void *b);
uint64 hashString(void *key);
bool comparatorString(void *a, void *b);

#if defined(COMMON_IMPL)

uint64 hashUInt64(void *k) {
	uint64 key = (uint64) k;
	key = (~key) + (key << 21); // key = (key << 21) - key - 1;
	key = key ^ (key >> 24);
	key = (key + (key << 3)) + (key << 8); // key * 265
	key = key ^ (key >> 14);
	key = (key + (key << 2)) + (key << 4); // key * 21
	key = key ^ (key >> 28);
	key = key + (key << 31);
	return key;
}

uint64 hashUInt32(void *k) {
	uint32 key = (uint32)((uint64) k);
	key += ~(key << 15);
	key ^= (key >> 10);
	key += (key << 3);
	key ^= (key >> 6);
	key += ~(key << 11);
	key ^= (key >> 16);
	return key;
}

bool comparatorBitwise(void *a, void *b) {
	return a == b;
}

uint64 hashString(void *key) {
	char *str = (char *) key;
	uint64 hash = 5381;
	int32 c;

	while ((c = *str++)) {
		hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
	}

	return hash;
}

bool comparatorString(void *a, void *b) {
	return strcmp((char *) a, (char *) b) == 0;
}

#endif


// Array of pointers definition.

#ifdef JOSIAH_INTERNAL
	#define PARRAYITEM(array, i, type) ((i < (array)->size && i >= 0) ? ((type *) (array)->items[i]) : (assert(false),(type *) 0))
	#define PARRAYITEMSLOT(array, i, type) ((i < (array)->size && i >= 0) ? ((type **) &(array)->items[i]) : (assert(false),(type **) 0))
#else
	#define PARRAYITEM(array, i, type) ((type *) (array)->items[i])
	#define PARRAYITEMSLOT(array, i, type) ((type **) &(array)->items[i])
#endif
#define PARRAYREMOVE(array, index) arrayRemove(array, index); --index;

struct PArray {
	void **items;
	uint64 size = 0, reserved = 0;
};

void ParrayNew(PArray *array, uint64 reserved);
PArray * ParrayNew(uint64 reserved);
void ParrayPush(PArray *array, void *push);
void * ParrayPop(PArray *array);
int ParrayAddUnique(PArray *array, void *item);
void ParrayRemove(PArray *array, uint64 index);

#if defined(COMMON_IMPL)

void ParrayNew(PArray *array, uint64 reserved) {
	assert(reserved != 0);
	array->items = (void **)malloc(reserved*sizeof(void *));
	assert(array->items);
	array->reserved = reserved;
	array->size = 0;
}

PArray * ParrayNew(uint64 reserved) {
	PArray *array = (PArray *)malloc(sizeof(PArray));
	assert(array);
	ParrayNew(array, reserved);
	return array;
}

void ParrayPush(PArray *array, void *push) {
	assert(array->reserved > 0);
	assert(array->items);

	if((++array->size*sizeof(void *)) > (array->reserved*sizeof(void *))) {
		// @TODO: better factor here, 1.5? @CONSIDER
		array->reserved *= 2;
		array->items = (void **)realloc(array->items, array->reserved*sizeof(void *));
	}
	array->items[array->size-1] = push;
}

void * ParrayPop(PArray *array) {
	if(array->size == 0) { return 0; }

	void *item = array->items[array->size-1];
	array->items[array->size-1] = 0;
	--array->size;

	// @TODO: realloc down if we go below a certain size
	return item;
}

int ParrayAddUnique(PArray *array, void *item) {
	for(int i = 0; i < array->size; ++i) {
		if(array->items[i] == item) {
			return i;
		}
	}

	ParrayPush(array, item);
	return -1;
}

void ParrayRemove(PArray *array, uint64 index) {
	for(uint64 i = index; i < array->size-1; ++i) {
		array->items[i] = array->items[i+1];
	}
	array->items[array->size-1] = 0;
	--array->size;
}

#endif


// MBlock allocator. This allocates fixed sized memory chunks from blocks of memory.
// @TODO: If I ever need to free ast nodes, I will switch to using this instead of my pool allocator.

struct MBlockList;
struct MBlock;
struct MBlockStorage;
struct MBlockList {
	PArray partial_blocks;
	PArray filled_blocks;
};

struct MBlockMetaData {
	MBlock *my_block;
	MBlockMetaData *next_first_free;
};

struct MBlock {
	MBlockList *my_block_list;
	uint64 index_in_list;

	void *memory;
	MBlockMetaData *current_first_free;
	uint64 size_of_items_stored;
	uint64 size;
	uint64 remaining;
	uint64 align;
	uint64 padding;
};

struct MBlockStorage {
	uint64 block_list_size;
	MBlockList *block_lists;
};

MBlock * blockCreate(uint64 num_items_to_store, uint64 size_of_items_to_be_stored, uint64 block_align);
void blockListInit(MBlockStorage *block_store, uint64 index_to_init, uint64 num_blocks_to_create, uint64 size_of_items_to_be_stored, uint64 block_align);
void blockFree(MBlockStorage *block_store, void *item);
void * blockAlloc(MBlockStorage *block_store, uint64 block_list_index);

#if defined(COMMON_IMPL)


MBlock * blockCreate(uint64 num_items_to_store, uint64 size_of_items_to_be_stored, uint64 block_align) {
	uint64 padding = getPadding(sizeof(MBlockMetaData), block_align);

	MBlock *block = (MBlock *) malloc(sizeof(MBlock) + (num_items_to_store * (sizeof(MBlockMetaData) + padding + size_of_items_to_be_stored)));
	assert(block);
	block->memory = (void *) (block + 1);
	block->current_first_free = (MBlockMetaData *) block->memory;
	block->size_of_items_stored = size_of_items_to_be_stored;
	block->size = block->remaining = num_items_to_store;
	block->align = block_align;
	block->padding = padding;

	MBlockMetaData *meta = block->current_first_free;
	for(int i = 0; i < num_items_to_store; ++i) {
		if(i+1 < num_items_to_store) {
			MBlockMetaData *next_meta = (MBlockMetaData *) (((char *) (meta+1)) + padding + size_of_items_to_be_stored); //(MBlockMetaData *) (block->memory+((i+1) * (sizeof(MBlockMetaData) + padding + size_of_items_to_be_stored)));
			meta->next_first_free = next_meta;
			meta->my_block = block;
			meta = next_meta;
		}
		else {
			meta->next_first_free = 0;
			break;
		}
	}
	return block;
}

void blockListInit(MBlockStorage *block_store, uint64 index_to_init, uint64 num_blocks_to_create, uint64 size_of_items_to_be_stored, uint64 block_align) {
	MBlockList *block_list = &block_store->block_lists[index_to_init];
	ParrayNew(&block_list->partial_blocks, num_blocks_to_create);
	ParrayNew(&block_list->filled_blocks, num_blocks_to_create);
	for(uint64 i = 0; i < num_blocks_to_create; ++i) {
		MBlock *block = blockCreate(100, size_of_items_to_be_stored, block_align);
		block->my_block_list = block_list;
		block->index_in_list = i;
		ParrayPush(&block_list->partial_blocks, (void *) block);
	}
}

void blockFree(MBlockStorage *block_store, void *item) {
	MBlockMetaData *meta = ((MBlockMetaData *) item)-1;
	if(meta->my_block->remaining == 0) {
		ParrayRemove(&meta->my_block->my_block_list->filled_blocks, meta->my_block->index_in_list);
		ParrayPush(&meta->my_block->my_block_list->partial_blocks, meta->my_block);
	}

	meta->next_first_free = meta->my_block->current_first_free;
	meta->my_block->current_first_free = meta;
	++meta->my_block->remaining;
}

void * blockAlloc(MBlockStorage *block_store, uint64 block_list_index) {
	PArray *partial = &block_store->block_lists[block_list_index].partial_blocks;
	PArray *filled = &block_store->block_lists[block_list_index].filled_blocks;

	MBlock *block = PARRAYITEM(partial, partial->size-1, MBlock);

	MBlockMetaData *meta = block->current_first_free;
	void *memory = (void *) (((char *) (meta + 1)) + block->padding);
	block->current_first_free = meta->next_first_free;

	--block->remaining;

	if(block->remaining == 0) {
		block->index_in_list = filled->size;
		ParrayPop(partial);
		ParrayPush(filled, (void *) block);
		if(partial->size == 0) {
			MBlock *new_block = blockCreate(100, block->size_of_items_stored, block->align);
			new_block->index_in_list = partial->size;
			new_block->my_block_list = &block_store->block_lists[block_list_index];
			ParrayPush(partial, (void *) new_block);
		}
	}

	return memory;
}

#endif


// Pool allocator, used when no deallocation is expected, or when only used as a stack.

struct Pool;
struct Pool {
	char *next;
	char *end;
};

Pool * poolCreate(uint64 size);
void poolFree(Pool *pool);
uint64 poolRemaining(Pool *pool);
void * poolAlloc(Pool *pool, uint64 size);
void poolDrop(Pool *pool);
void * poolNote(Pool *pool);
void poolRestore(Pool *pool, void *note);

#if defined(COMMON_IMPL)


Pool * poolCreate(uint64 size) {
	Pool *pool = (Pool *) malloc(size+sizeof(Pool));
	pool->next = (char *) &pool[1];
	pool->end = pool->next + size;

	return pool;
}

void poolFree(Pool *pool) {
	free(pool);
}

uint64 poolRemaining(Pool *pool) {
	assert(pool->next < pool->end);
	return (uint64) (pool->end - pool->next);
}

void * poolAlloc(Pool *pool, uint64 size) {
	if(poolRemaining(pool) < size) { return 0; }
	void *memory = (void *) pool->next;
	pool->next += size;
	return memory;
}

void poolDrop(Pool *pool) {
	pool->next = (char *) &pool[1];
}

// Used when the pool is being used like a stack.
void poolDrop(Pool *pool, uint64 size) {
	pool->next -= size;
}

void * poolNote(Pool *pool) {
	return pool->next;
}

void poolRestore(Pool *pool, void *note) {
	assert(note < pool->end && note > (char *) pool);
	pool->next = (char *) note;
}

#endif

// Pointer-pointer hash

#define PP_HASH_INSERT(table, key, value) (table = ppInsert(table, (void *) key, (void *) value))

struct PPEntry;
struct PPTable;

PPTable * ppCreate(uint64 capacity = 100);
void * ppLookup(PPTable *table, void *key);
PPTable * ppInsert(PPTable *table, void *key, void *value);
void ppUpdate(PPTable *table, void *key, void *new_value);

#if defined(COMMON_IMPL)

struct PPEntry {
	void *key;
	void *value;
};

struct PPTable {
	PPEntry *entries;
	uint64 size;
	uint64 capacity;
};

PPTable * ppCreate(uint64 capacity) {
	PPTable *table = (PPTable *) calloc(sizeof(PPTable) + (capacity * sizeof(PPEntry)), 1);
	table->entries = (PPEntry *) (table+1);
	table->size = 0;
	table->capacity = capacity;

	return table;
}

void * ppLookup(PPTable *table, void *key) {
	uint64 hash = ((uintptr_t) key) % table->capacity;

	PPEntry entry = table->entries[hash];

	while(entry.key != key && entry.key != 0) {
		hash = (hash+1) % table->capacity;
		entry = table->entries[hash];
	}

	return entry.value;
}

PPTable * ppInsert(PPTable *table, void *key, void *value) {
	if(++table->size >= table->capacity) {
		PPTable *new_table = ppCreate(table->capacity * 2);

		for(uint64 i = 0; i < table->capacity; ++i) {
			PPEntry entry = table->entries[i];

			if(entry.key != 0) {
				PP_HASH_INSERT(new_table, entry.key, entry.value);
			}
		}

		free(table);
		table = new_table;
	}

	uint64 hash = ((uintptr_t) key) % table->capacity;

	while(table->entries[hash].key != 0) {
		hash = (hash+1) % table->capacity;
	}

	table->entries[hash].key = key;
	table->entries[hash].value = value;

	return table;
}

void ppUpdate(PPTable *table, void *key, void *new_value) {
	uint64 hash = ((uintptr_t) key) % table->capacity;

	while(table->entries[hash].key != key && table->entries[hash].key != 0) {
		hash = (hash+1) % table->capacity;
	}

	table->entries[hash].value = new_value;
}

#endif

// Unicode

const char * findPreviousUTF8Char(const char *ptr, const char *start, uint64 count);

#if defined(COMMON_IMPL)

const char * findPreviousUTF8Char(const char *ptr, const char *start, uint64 count) {
	do {
		ptr--;
		if (ptr < start) {
			return 0;
		}

		if((*ptr & 0xC0) != 0x80) {
			count--;
		}
	} while (count > 0);

	return ptr;
}

#endif

#ifdef JOSIAH_MAC
	#define PLATFORM_IMPL
	#include "platform_mac.h"
	#undef PLATFORM_IMPL
#endif