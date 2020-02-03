# awg-matlab
Start with the examples in `examples/` directory.

## Important notes
* All lengths are [µm] and frequencies are [THz] by default. This means, for example, that 1550nm wavelength will be written 1.55 and 193.5THz is simply 193.5.

* The model currently only handles strip waveguides with constant 220nm height, widths may vary from 350nm to 2µm, freespace wavelength must be within 1.4 to 1.6µm, core material is Silicon.

* Spot size gaussian approximation is used by default to calculate strip waveguide profiles. It is possible to use real modes by including the option `‘RealModes’, true` in the transfer function script inputs (see example 2).

* When running example scripts, make sure the active directory is the root AWG model directory and not the examples directory.
