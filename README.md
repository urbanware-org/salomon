# *SaLoMon* <img src="https://raw.githubusercontent.com/urbanware-org/salomon/master/icons/salomon_256x256.png" alt="SaLoMon logo" height="48px" width="48px" align="right"/>

**Table of contents**
*   [Definition](#definition)
*   [Details](#details)
*   [Usage](#usage)
*   [Requirements](#requirements)
*   [Contact](#contact)
*   [Useless facts](#useless-facts)

----

## Definition

The *SaLoMon* project is a simple log file monitor and analyzer with various filter and highlighting features which can also be used with other plain text files.

[Top](#salomon-)

## Details

The main script was primarily built to monitor and analyze log as well as plain text files on systems without a graphical user interface. It returns either all or just certain lines (by applying a filter) that have been added to the monitored file or multiple files.

These lines can also easily be colorized with user-defined colors (and additionally highlighted in different ways) depending on given criteria. For example, all lines which contain the word "error" can be displayed red.

<img src="https://raw.githubusercontent.com/urbanware-org/salomon/master/wiki/salomon_dialog_inputfile.png" alt="SaLoMon interactive dialog" align="right"/>

There are various additional combinable features, for example giving a filter, exclude and remove pattern to filter and customize the output.

Furthermore, as you can see on the right, there is the option to use interactive dialogs instead of or in combination with command-line arguments which is useful when e. g. running *SaLoMon* via shortcut in a terminal window on a graphical user interface.

[Top](#salomon-)

## Usage

### Quick start

You can get started with *SaLoMon* in less than two minutes by reading the [quick start guide](../../wiki/Quick-start).

### Documentation

You can find a fundamental documentation inside the [wiki](../../wiki).

In the `docs` sub-directory of the project, there are plain text files containing a detailed documentation for each component with further information and usage examples.

[Top](#salomon-)

## Requirements

The *SaLoMon* project was developed on (and for) the *Bash* shell, which is the default shell on many *Unix*-like systems (or at least *Linux* distributions).

Furthermore, it uses popular shell utilities that should be pre-installed by default, see the included `REQUIREMENTS` file for details.

[Top](#salomon-)

## Contact

Any suggestions, questions, bugs to report or feedback to give?

You can contact me by sending an email to <dev@urbanware.org>.

Further information can be found inside the `CONTACT` file.

[Top](#salomon-)

## Useless facts

*   The project name is an abbreviation for ***Sa****ne* ***Lo****g* *File* ***Mon****itor*.
*   The first version uploaded on *GitHub* was *SaLoMon* 1.6.2 built on April 30<sup>th</sup>, 2015.

[Top](#salomon-)
