// build with: gcc -fPIC -shared -o libdl.so -Wl,--soname='libdl.so.2' libdl.c

void dlopen() { }

void dlsym() { }

void dladdr() { }

void dlclose() { }

void dlerror() { }

void __libc_start_main() { }