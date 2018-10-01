# Inplace execution
Sometimes you _must_ run PDQTest inplace, on the computer your running from. 

This is mostly useful for CI systems where running Docker-In-Docker is too
slow/heavy.

## Warning
**Do not run PDQTest inplace on a system you care about**

It will run puppet against it and likely destroy the system depending what your
tests look like

## Requirements
The current system must have available in `PATH`:
* Puppet
* BATS (Linux) or PATS (Windows)
* PDK

## Activation
You have to run PDQTest with the options `--inplace --inplace-enable` to 
activate inplace alteration. This is normally done from CI integration files.

## Problems in-place execution solves
* Acceptance testing on Bitbucket Pipelines.
* Acceptance testing Windows on Appveyor

## Example project
https://bitbucket.org/geoffwilliams_pp/test