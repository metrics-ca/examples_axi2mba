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

echo "================= Analyze ==================="
dvlcom +ignore+protect +ignore+endprotect +incdir+../../vflib/lib+../../vflib/axi+../../vflib/common+../../vflib/pin \
  -sv -timescale 1ns/1ns +define+NO_PLI +libext+.v+.vp+.vlog +incdir+..+../../common+../../../rtl/sram+../../../rtl/axi2mba+/common+/lib+/axi+/pin+../../mba+..+../include \
  -y .. -y ../../common -y ../../../rtl/sram -y ../../../rtl/axi2mba -l dvlcom-1.log \
  ../tb_top.vlog
dvlcom +ignore+protect +ignore+endprotect +incdir+../../vflib/lib+../../vflib/axi+../../vflib/common+../../vflib/pin \
  -sv -timescale 1ns/1ns +define+NO_PLI +libext+.v+.vp+.vlog +incdir+..+../../common+../../../rtl/sram+../../../rtl/axi2mba+/common+/lib+/axi+/pin+../../mba+..+../include \
  -y .. -y ../../common -y ../../../rtl/sram -y ../../../rtl/axi2mba -lib $design \
  -l dvlcom.log ../tests/$design.sv
