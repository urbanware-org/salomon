# *SaLoMon*

## Definition

The *SaLoMon* project is a simple tool to monitor or analyze log as well as plain text files and colorize as well as highlight lines containing certain terms.

## Details

The main script was primarily built to monitor and analyze log as well as plain text files on systems without a graphical user interface. It returns either all or just certain lines (by applying a filter) that have been added to the monitored file.

These lines can also easily be colorized with user-defined colors (and additionally highlighted) depending on given criteria. For example, all lines which contain the word "error" can be displayed red.

## Requirements

The script uses popular shell utilities that should be pre-installed by default on *Unix*-like systems, see the included `requirements.txt` file.

> :information_source: **Notice:**
>
> The *SaLoMon* project was developed on (and for) the *Bash* shell, which is the default shell on many *Unix*-like systems (or at least Linux distributions).
>
> No matter which shell you are using, the *Bash* shell must be installed in order to use *SaLoMon*.

## Current development state

The development of the *SaLoMon* project has been placed on hold for now.

The main reason for this decision was the increased complexity of the code as well as the fact that maintaining it has become quite laborious.

Furthermore, the project is written entirely in shell code which works fine so far, but does not provide the features programming languages like *Python* do.

## Useless facts

* The project name is an abbreviation for ***Sa****ne* ***Lo****g* *File* ***Mon****itor*.
* The first version uploaded on *GitHub* was *SaLoMon* 1.6.2 built on April 30th, 2015.
* The included text files such as `readme.txt` and `license.txt` have lower-case names and an extension even though the usual format is upper case without any extension.
