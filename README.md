# awg-matlab v0.8.1

Arrayed waveguide grating (AWG) simulator for nanophotonics designed as a series of functional blocks. See the example script file for an AWG simulation where the design parameters may be tweaked. The apps folder contains an installer for a self-contained app with an intuitive graphical user interface producing the overall inssertion loss spectrum for the provided design parameters.

## Installation

### Dependencies

The source code provided and the app GUI have been developed for Matlab version R2019b and are not guarantied to be backward compatible.

### Instructions

In order to use this library, the current folder and subfolders should be on the Matlab path. To include them dynamically from code, simply add the command:

```matlab
addpath(genpath(<relative-path-to-awg-matlab-folder>));
```

To install the provided app GUI as a Matlab Application, simply run the AWGSimulator.mlappinstall file from within Matlab.

## Contributing

Please file any issues encountered to: github.com/dnrobin/awg-matlab/issues

To contribute to the source code:

. Fork a copy of the project
. Clone that copy to your local machine
. Make edits/contributions
. Commit and push changes to your branch
. Create a pull request

## Version history

### Version 0.8.1 (Oct 24, 2020)
* fixed missing dependencies

### Vesrion 0.8 (Oct 23, 2020)
* added packaged Matlab App
* simplified overall project structure
* fixed some incorrect math equations

### Version 0.1 (Feb 3, 2020)
* initial model release