# awg-matlab v1.0.1

Arrayed waveguide grating (AWG) simulator for nanophotonics designed as a series of functional blocks in an object oriented architecture. See the example script file for an AWG simulation where the design parameters may be tweaked.

## Installation

### Dependencies

The source code provided has been developped and tested for Matlab version R2019b and is not guarantied to be backward compatible.

### Instructions

In order to use this library, the current folder and ./public folder should be on the Matlab path. To include them dynamically from code, simply add the following command to the begining of the script:

```javascript
addpath(genpath(<relative-path-to-awg-matlab-folder>));
```

## Contributing

Please file any issues encountered to: github.com/dnrobin/awg-matlab/issues

To contribute to the source code:

* Fork a copy of the project
* Clone that copy to your local machine
* Make edits/contributions
* Commit and push changes to your branch
* Create a pull request on the 'v1beta' branch

## Version history

### Version 1.0.1 (Nov 24, 2020)
* initial model v1 constructed from v0 to be fully extendible