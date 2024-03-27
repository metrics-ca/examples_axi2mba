#!/bin/sh
BINDIR=../../common/scr

TARGET=
SOPTS=
SLOG=
TOPS=
RUN64=
SEED=
VSIM_DO=

load_rc () {
  [ -z "$1" ] && return
  if [ -f "$1" ]; then
    echo "Load \"$1\""
    . $1
  fi
}

load_rc $BINDIR/common.rc
load_rc ../rc/common.rc
load_rc ./common.rc

load_rc $BINDIR/sim.rc
load_rc ../rc/sim.rc
load_rc ./sim.rc

SIMV=./simv
VSIM=vsim
NCSIM=ncsim
NCVERILOG=ncverilog

help () {
cat <<- HELP
	Usage $0 TARGET [OPTION] [-o OPT]... [[-t|-top] TOP]...
	  Options:
	    -vcs | -vcsi | -vcsmx | -vcsmxi | -mti | -ius : target EDA
	    -h, -help          : show this help
	    -l, -log LOG       : specify the simulation log file name
	    -seed SEED         : specify the initial random seed
	    -do DOFILE         : specify the initial do script (for MTI)
	    -64                : in 64-bit mode (default: 32-bit, for MTI)
	    -o OPT             : specify the simulation option
	    -t, -top TOP       : specify the top name
	    TOP                : specify the top name (same with -t, -top)
HELP
}

sim_vcs () {
  [ -x "$SIMV" ] || { echo "$SIMV: no such file."; exit 1; }
  $SIMV $SOPTS \
        +vcs+lic+wait \
        -l $SLOG \
        ${SEED:++ntb_random_seed=$SEED}
}

sim_mti () {
  [ -n "$RUN64" ] && export MTI_VCO_MODE=64 || export MTI_VCO_MODE=32
  if [ -z "$VSIM_DO" ]; then
    [ -f "$BINDIR/vsim.do" ] && VSIM_DO="$BINDIR/vsim.do"
    [ -f "../rc/vsim.do" ] && VSIM_DO="../rc/vsim.do"
  fi

  $VSIM $SOPTS \
        -c \
        +no_tchk_msg \
        +notimingchecks \
        -onfinish stop \
        -l $SLOG \
        ${SEED:+-sv_seed $SEED} \
        ${VSIM_DO:+-do $VSIM_DO} \
        $TOPS
}

sim_ius () {
  $NCVERILOG \
      -R \
      ${RUN64:++nc64bit} \
      $SOPTS \
      -l $SLOG \
      ${SEED:+-seed $SEED}
}

### Read command line arguments
echo "$0 $*"
while [ $# -gt 0 ] ; do
  case "$1" in
    -vcs|-vcsi)
      TARGET="vcs";;
    -vcsmx|-vcsmxi)
      TARGET="vcsmx";;
    -mti)
      TARGET="mti";;
    -ius)
      TARGET="ius";;
    -h|-help)
      TARGET="help";;
    -seed)
      shift; SEED=$1;;
    -do)
      shift; VSIM_DO=$1;;
    -l|-log)
      shift; SLOG=$1;;
    -o)
      shift; SOPTS="$SOPTS $1";;
    -t|-top)
      shift; TOPS="$TOPS $1";;
    -64)
      RUN64=1;;
    -32)
      RUN64=;;
    *)
      TOPS="$TOPS $1";;
  esac
  shift
done

TARGET=${TARGET:-vcsmx}
SLOG=${SLOG:-sim-$TARGET${SEED:+-seed$SEED}.log}

case "$TARGET" in
  vcs|VCS|vcsmx|VCSMX) sim_vcs;;
  mti|MTI) sim_mti;;
  ius|IUS) sim_ius;;
  help|HELP) help; exit 1;;
  *) echo "$TARGET: no such target"; exit 1;;
esac

exit 0
# end of file
