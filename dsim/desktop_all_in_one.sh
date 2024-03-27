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

# Assign arguments to variables with default value for sim_time
design=$1
sim_time=${2:-10}

# Validate simulation time - ensure it is an integer
if ! [[ "$sim_time" =~ ^[0-9]+$ ]]; then
    echo "Error: simulation_time must be an integer."
    exit 1
fi

./desktop_clean.sh
./desktop_analyze.sh $design
./desktop_elaborate.sh $design
./desktop_run.sh $design $sim_time
