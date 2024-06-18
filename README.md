# Axi2mba Sample Design
There are multiple ways to use the DSim simulator; locally and in the cloud, from the terminal and from the DSim Desktop UI.
This README contains a examples of how to use each of these flows for this sample design.

## Prerequisites
* DSim Desktop is installed
* At least one version of DSim is installed and activated
* DSim Cloud CLI tool (`mdc`) is installed in order to run `Simulation in the Cloud at scale`
* Operating Systems
    * Local running of DSim is supported on Windows and various flavours of Linux
    * Running in the Cloud with DSim Desktop and `mdc` is supported on Windows, Linux, and MacOS

## Get Started
1. Open VSCode
2. Open the directory containing this design
    - Ensure only this directory is loaded. 
    - ex. Don't open your home directory with the project as a subdirectory
2. Open the project in DSim Desktop
    - From the Explorer `dsim/axi2mba.dpf` -> right-click -> `DSim Desktop: Open Project`

## Simulate Locally with DSim Desktop
2. Compile
    - From DSim Desktop -> Compile Project
3. Run Simulation
    - From DSim Desktop -> Select the `Run` icon next to a simulation configuration.
    - View output in the `OUTPUT` panel.


## Simulation in the Cloud with One-Click Simulation
1. One-Click Simulation
    - From DSim Desktop -> Click the `Run in DSim Cloud` icon next to a simulation configuration.
    - View progress in the `JOBS` panel in DSim Desktop

## Simulate Locally in the DSim Desktop Terminal
1. Open a DSim Desktop Terminal
    - From VSCode -> Terminal Panel -> New Terminal Selector -> DSim Desktop
        - cd to `dsim`
        - run `desktop_all_in_one.sh test2`
    - To run other tests supply one of the following available tests
        - `test1`, `test2`, `test3`, `test4`
    - To vary the simulation time provide an argument to the script for number of simulation ms
        - `desktop_all_in_one.sh test2 500`

## Simulation in the Cloud at scale with the Metrics DSim Cloud CLI (`mdc`)
1. Ensure you have `mdc` installed.
2. Open a terminal and cd into the design folder where this README file is located.
3. Login with `mdc` if not already authenticated
    - `mdc auth login`
4. Submit the provided job file
    - From VSCode -> Terminal Panel -> New Terminal Selector -> DSim Desktop
        - `mdc job submit dsim/axi2mba-fanout-basic.yaml`
    - View progress in the `JOBS` panel in DSim Desktop
    - To vary number of simulations and time edit the `fanout` properties for the `sim-test2-sim` task in the job yaml
        
