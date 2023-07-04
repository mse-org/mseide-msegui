Demo to show the options to link libc.so with different signed symbols tables.

The options can be changed with Project-Options.

1) When using in tab "Make" option "-dglibc225" + in tab "Command before" second line + in tab "Command after" first line, the oldest GLIBC_2.2.5 will be used.
   The binary will run on older distros, present and futures.

2) When using only in tab "Command before" first line + in tab "Command after" first line, the "unsigned" symbols will be assigned.
   At running the binary will use the last table of the libc.so host. The binary will run on older distros, present and should be ok on future versions.

3) Without any option (like it is by default) the linker will assign the last table of the sytsem that compiles.
   The binary will run on same systems as the compilation-system, futures too but not on system with previous version.


You may check the result of each option-method via a terminal.

> cd /directory-of-mseide-msegui/tools/timeless_clock/mseclock/

> objdump -T mseclock | grep "("
   
You will have the list of the versioned symbol for each method used.

With option/method:

 1) You should see only @GLIBC_2.2.5 signature for all methods.
 2) Some methods of 1) are unisigned, they are part now of the "Base" symbols. (you may check with grep "Base")
 3) The majority of signature is @GLIBC_2.2.5 but there are some @GLIBC_2.34 or higher.


