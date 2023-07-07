    __asm__(".symver dlopen, __placeholder@@"); // GLIBC_2.2.5");
    void dlopen() { }
    __asm__(".symver dlsym, __placeholder@@"); // GLIBC_2.2.5");
    void dlsym() { }
    __asm__(".symver dladdr, __placeholder@@"); // GLIBC_2.2.5");
    void dladdr() { }
    __asm__(".symver dlclose, __placeholder@@"); // GLIBC_2.2.5");
    void dlclose() { }
    __asm__(".symver dlerror, __placeholder@@"); // GLIBC_2.2.5");
    void dlerror() { }