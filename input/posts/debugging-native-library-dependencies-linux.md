Title: Debugging native library dependencies on Linux
Published: 04/04/2020
Tags:

 - ldd
 - dotnet
 - linux
---

.NET Core apps can run on a number of operating systems. When using purely .NET libraries, deployment is a breeze. However, if you're using a library that wraps a native (C/C++) library, then you might have come across this error message when trying to run your app on Linux:

```
System.TypeInitializationException: The type initializer for 'DlibDotNet.NativeMethods' threw an exception.
 ---> System.DllNotFoundException: Unable to load shared library 'DlibDotNetNativeDnn' or one of its dependencies. In order to help diagnose loading problems, consider setting the LD_DEBUG environment variable: libDlibDotNetNativeDnn: cannot open shared object file: No such file or directory
```

This tells us that either `libDlibDotNetNativeDnn.so` doesn't exist (which in my case it did), or it has some other native dependencies that are missing. 

To see which dependencies are missing, you use `ldd`:

```
ldd libDlibDotNetNativeDnn.so
```

And it would give you an output like this:

```
linux-vdso.so.1 (0x00007ffdb9fe1000)
libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f06b2254000)
libopenblas.so.0 => not found
libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f06b2072000)
libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f06b1f24000)
libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f06b1f0a000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f06b1d1d000)
/lib64/ld-linux-x86-64.so.2 (0x00007f06b490d000)
```

Now it's clear that `libopenblas` is missing from the system. Search for it on google and find the package that contains the library. In `libopenblas`'s case, it happens to be in the `libopenblas-base` . To install it on ubuntu, you can run:

```
sudo apt-get install libopenblas-base
```

Tada 🎉 and now your app (hopefully) works as expected!

This little error wasted several hours from me. I am grateful to the people who maintain these native library wrappers and hide (most of) the ugliness from us.