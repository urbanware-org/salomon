# *Salomon* <img src="https://raw.githubusercontent.com/urbanware-org/salomon/master/icons/png/salomon_256x256.png" alt="Salomon logo" height="128px" width="128px" align="right"/>

**Table of contents**
*   [Definition](#definition)
*   [Details](#details)
*   [Usage](#usage)
*   [Requirements](#requirements)
*   [Support the project](#support-the-project)
*   [Contact](#contact)
*   [Useless facts](#useless-facts)

----

## Definition

The *Salomon* project is a simple log file monitor and analyzer with various highlighting and filtering features which can also be used with other plain (non-binary) text files.

It runs on *Linux* and since version 1.21.0 also on [*BSD*](../../wiki/Running-salomon-on-bsd) derivates.

[Top](#salomon-)

## Details

<img src="https://raw.githubusercontent.com/urbanware-org/salomon/master/wiki/salomon_output.png" alt="Salomon sample output" width=320px align="right"/>The project was primarily built to monitor and analyze log files inside a terminal emulator and also on systems without a graphical user interface. Of course, you can use the features of *Salomon* with other plain text files of any kind.

The input files will be processed line by line.

Each line can easily be colorized with a user-defined color (and additionally highlighted in different ways) depending on given criteria. For example, all lines which contain the word "error" can be displayed red and those that contain the word "success" can be displayed green (as shown above). Furthermore, the output can be filtered to only return certain lines instead of all.

<img src="https://raw.githubusercontent.com/urbanware-org/salomon/master/wiki/salomon_dialog_inputfile.png" alt="Salomon interactive dialog" align="right"/>There are various additional combinable features such as multiple ways to filter the output (e.g. by using exclude and remove patterns) and different methods to additionally highlight the filter terms. The output can also be paused or slowed down with a user-defined delay.

Furthermore, as you can see on the right, there is the option to use interactive dialogs instead of or in combination with command-line arguments which is useful when e.g. running *Salomon* via shortcut in a terminal window on a graphical user interface.

[Top](#salomon-)

## Usage

### Quick start

You can get started with *Salomon* in less than two minutes by reading the [quick start guide](../../wiki/Quick-start).

### Documentation

You can find a fundamental documentation inside the [wiki](../../wiki).

In the `docs` sub-directory of the project, there are plain text files containing a detailed documentation for each component with further information and usage examples.

[Top](#salomon-)

## Requirements

The *Salomon* project was developed on (and for) the *Bash* shell and it uses popular shell utilities that should be pre-installed by default.

Details can be found [here](../../wiki/Home#requirements) inside the [wiki](../../wiki) as well as in the included `REQUIREMENTS` file.

[Top](#salomon-)

## Support the project

You do not need to be a software developer to support the project.

If you have any requests or suggestions for improving or extending *Salomon*, its documentation or the color schemes, just let me know.

For example, if you have created a color config file for a log file which you want to share, you can send it to me so I can add it to the color config files distributed with *Salomon* by default.

[Top](#salomon-)

## Contact

Any suggestions, questions, bugs to report or feedback to give?

You can contact me by sending an email to [dev@urbanware.org](mailto:dev@urbanware.org) or by opening a *GitHub* issue (which I would prefer if you have a *GitHub* account).

Further information can be found inside the `CONTACT` file.

[Top](#salomon-)

## Useless facts

Whoever cares can find them [here](../../wiki#useless-facts).

[Top](#salomon-)
