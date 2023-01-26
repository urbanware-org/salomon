# Building a customized release

Repository clones of *Salomon* include `make.sh` which is some sort of release builder script. As this statement suggests, it is not a part in the official release.

This script is used to create the archive and the corresponding checksum file for the official releases of the original repository. The archive contains all project relevant files (including the source code) without any of the *GitHub* specific files that are not necessary in order to use the project.

When you download a release of *Salomon* outside this *GitHub* repository (or the one from [*GitLab*](https://gitlab.com/urbanware-org/salomon)), you can verify that it is an official one without modified content by using the SHA256 checksum file provided by the corresponding release [here](https://github.com/urbanware-org/salomon/releases).

## Custom content

Nevertheless, you can create an archive for your own purposes (with customized scripts, color schemes, filters etc.).

If you want you can also send your custom files to make them officially added to the *Salomon* release. Files such as color schemes and filters can simply been sent by mail or via issue.s

The author will be mentioned in a contributor file, but the contribution can also be anonymous if desired. Personally, I would be pleased with the former.

However, in case you want to share your customized version, a corresponding notice is required that it is not an official release.

Please note the following:

*   The original files `README` and `CHANGELOG` must remain untouched.

*   The file `MODIFIED` must be created and placed in the same directory where the above files are located.

*   This file must contain all information about the customized version (author, modifications, changelog etc.). See the `MODIFIED` file example below for details.

When done, simply run `make.sh` without any command-line arguments

```
./make.sh
```

which will create the archive containing your customized version and the corresponding checksum.

### Example file

The structure of the file is up to you, it just needs to contain the required information.

```
Modified Salomon version

Some modification of Salomon which makes all output lines flash in random
colors which is absolutely useless. However, that does not matter as this file
is just an example for a file that indicates the version of Salomon has been
modified.

Author: John Doe
Date:   2021-04-27

Changelog:
    2021-04-27  Replaced foo with foobar
    2021-04-26  Added foo
```
