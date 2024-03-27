#!/bin/sh

INIT_SEED=3000
NUM_SEED=500
TOP="-t tb_top -t test"
COMPILE_OPT="-sv -64 $TOP ../tb_top.vlog"
SIM_OPT="-64 $TOP -o +warn=noFCICIO"

COMPILE=../../common/scr/compile.sh
SIM=../../common/scr/sim.sh
SUMMARY=log_summary.txt

exec_regress () {
  $COMPILE -c
  $COMPILE $COMPILE_OPT $TEST

  seed=$START_SEED
  while [ $seed -le $END_SEED ]; do
    LOGNAME=${TEST%.*}
    LOGNAME="sim-${LOGNAME##*/}-seed${seed}.log"
    $SIM $SIM_OPT -l $LOGNAME -seed $seed
    seed=$(expr $seed + 1)
  done
}

chk_summary () {
  [ -f $SUMMARY ] || return
  local RVAL=0
  grep -q "WARNING=[1-9]" $SUMMARY
  if [ $? -eq 0 ]; then
    echo "Found WARNING(s)!! Check $SUMMARY"
    RVAL=2
  else
    echo "Found no warnings"
  fi
  grep -q "FAILED" $SUMMARY
  if [ $? -eq 0 ]; then
    echo "Found FAILD simulation(s)!! Check $SUMMARY"
    RVAL=1
  else
    echo "All simulations passed"
  fi
  return $RVAL
}

# DQTYPE=x32
START_SEED=$INIT_SEED
END_SEED=$(expr $START_SEED + $NUM_SEED)
TEST="../tests/test3.sv"
exec_regress

# DQTYPE=x16
START_SEED=$(expr $INIT_SEED + 1000)
END_SEED=$(expr $START_SEED + $NUM_SEED)
TEST="../tests/test4.sv"
exec_regress

# SLVERR
START_SEED=$(expr $INIT_SEED + 2000)
END_SEED=$(expr $START_SEED + $NUM_SEED)
TEST="../tests/test2.sv"
exec_regress

rm -f $SUMMARY
grep "DQTYPEx"      sim-test2*.log | tee -a $SUMMARY
grep "\[WARNING\]"  sim-test*.log  | tee -a $SUMMARY
grep "\[ERROR\]"    sim-test*.log  | tee -a $SUMMARY
grep "^Simulation " sim-test*.log  | tee -a $SUMMARY

chk_summary
exit $?

# end of file
