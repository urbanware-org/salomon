# Compiling *Salomon*

The main *Salomon* script and its core modules can be compiled into a single binary. This served as a test whether the performance of the program could be increased. In some cases it slightly is faster, but not in many (almost none to be precise).

For this purpose, the main script is merged with the core modules into a single all-in-one script file (does not require using `source` for the core modules anymore) which is then compiled using the generic shell script compiler `shc`.

However, latter does not actually compile the script in the traditional sense. Instead, `shc` converts the script into _C_ source code in a certain way, which is then compiled into a binary. So, there are no improvements which increase the performance in any way. Details can be found in its manpage.

In case someone is interested in compiling (for whatever reason) the `compile.sh` script can be used to create the binary containing all the functionality.

After that, the `core` sub-directory is obsolete (for running the binary) and could theoretically be deleted, but this would break all script files (their functionality to be precise) like the installation, help and main script as well.

You could also merge the script files (the way it is done in `compile.sh`) without compiling them to avoid using `source`, but the code will become a mess then.

As mentioned above, this was a test and not meant for productive use. Furthermore, there is no guarantee that the compiled version works properly.

In short, compiling *Salomon* is useless, but the script shows how it can be done.
