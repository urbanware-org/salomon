# Compiling *Salomon*

In short, compiling *Salomon* is **absolutely useless**, but in case someone is interested in compiling (for whatever reason), the details can be found below.

The main *Salomon* script and its core modules can be compiled into a single binary using `compile.sh`. This served as a test whether the performance of the program could be increased.

For this purpose, the main script is merged with the core modules into a single all-in-one script file (does not require using `source` for the core modules anymore) which is then compiled using the generic shell script compiler `shc`.

However, `shc` is more of a code obfuscator than a real compiler, so there is no performance increase at all.

After compiling, the `core` sub-directory is obsolete (for running the binary) and could theoretically be deleted, but this would break all script files (their functionality to be precise) like the installation, help and main script as well.

You could also merge the script files (the way it is done in `compile.sh`) without compiling them to avoid using `source`, but the code will become a mess then.

As mentioned above, this was a test and not meant for productive use. Furthermore, there is no guarantee that the compiled version works properly.
