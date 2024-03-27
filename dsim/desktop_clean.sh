#!/bin/bash

cleanup() {
    popd
}
trap cleanup EXIT

pushd ../tb/axi2mba/work.regress/
rm -r dsim_work
