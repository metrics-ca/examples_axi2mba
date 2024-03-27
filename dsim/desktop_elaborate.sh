#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: $0 <design>"
    echo
    echo "Arguments:"
    echo "  design          The design parameter for the script."
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi

design=$1

cleanup() {
    popd
}
trap cleanup EXIT

pushd ../tb/axi2mba/work.regress/

echo "================= Elaborate ==================="
dsim -genimage $design -allow-int-enum-assign -top work.tb_top -top $design.test +acc+b 