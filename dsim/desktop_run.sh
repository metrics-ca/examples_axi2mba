#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: $0 <design> [simulation_time]"
    echo
    echo "Arguments:"
    echo "  design          The design parameter for the script."
    echo "  simulation_time Optional. The simulation time in seconds. Default is 10."
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi
design=$1
sim_time=${2:-10}

cleanup() {
    popd
}
trap cleanup EXIT

pushd ../tb/axi2mba/work.regress/
echo "================= Run ==================="
dsim -image $design +sim_time=$sim_time