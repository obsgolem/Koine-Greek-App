#ifndef PLATFORM_IMPL

#include <sys/stat.h>

#else

struct Buffer {
	FILE *file;
};

// Vulnerable to race conditions,  I don't care.
char * readEntireFile(const char *name) {
	FILE *file;
	file = fopen(name, "rb");
	if(file == 0) {
		return 0;
	}

    struct stat st;
    fstat(fileno(file), &st);
    uint64 size = st.st_size;

	// fseek(file, 0, SEEK_END);
	// uint64 size = (uint64) ftell(file);
	// fseek(file, 0, SEEK_SET);

	char *data = NstringCreate(size);
	NARRAY_SIZE_WRITABLE(data) = size;

	fread(data, size, 1, file);
	fclose(file);

	return data;
}

Buffer * createWritableFile(const char *name) {
	Buffer *buffer = (Buffer *) malloc(sizeof(Buffer));
	buffer->file = fopen(name, "w");

	return buffer;
}

void writeBuffer(Buffer *buffer, const char *data, ...) {
	va_list v_args;

	va_start(v_args, data);
	vfprintf(buffer->file, data, v_args);
	va_end(v_args);
}

void closeBuffer(Buffer *buffer) {
	free(buffer);
}

#endif