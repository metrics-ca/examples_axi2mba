#!/bin/sh
BINDIR=../../common/scr

TARGET=
COPTS=
CLOG=
DLOG=
ELOG=
SLOG=
TESTS=
TOPS=
RUN64=
VLOGVER=

TIMESCALE='1ns/1ns'
DEFINES='NO_PLI'
INCDIRS=''
LIBDIRS=''
LIBEXTS='.v .vp .vlog'
VLOGARGS=''
VHDLARGS=''

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

load_rc $BINDIR/compile.rc
load_rc ../rc/compile.rc
load_rc ./compile.rc

RM=rm
TEE=tee
VCS=vcs
VLOGAN=vlogan
VHDLAN=vhdlan
VLOG=vlog
VCOM=vcom
VLIB=vlib
VDEL=vdel
VLIBWORK=work
NCVLOG=ncvlog
NCELAB=ncelab
NCVERILOG=ncverilog
CLEAN_ONLY=0

help () {
cat <<- HELP
	Usage $0 TARGET [OPTION] [TEST]...
	  TARGET:
	    -vcs | -vcsi | -vcsmx | -vcsmxi | -mti | -ius : target EDA
	  Options:
	    -h, -help          : show this help
	    -l, -log LOG       : specify the compile log file name
	    -c, -clean         : clean only (no compile)
	    -t, -top TOP       : specify the top name (for VCSMX, VCSMXi)
	    -64                : in 64-bit mode (default: 32-bit)
	    -v2k               : in Verilog-2001 (default: SystemVerilog)
	    -d DEFINE          : specify the define
	    -o OPT             : specify the compile option
	    -fl FILE           : specify the Verilog file list
	    -fc FILE           : specify the VHDL file list
	    TEST               : specify the test file name
HELP
}

clean_vcs () {
  $RM -f $CLOG $DLOG $ELOG $SLOG
  $RM -fr ./csrc ./simv.daidir ./simv.vdb ./simv.cm ./AN.DB ./64
  $RM -f  ./simv ./vc_hdrs.h ./vcdplus.vpd ./vcs.key ./ucli.key
  $RM -f  ./vhdl.sdb ./vhmra.sdb
  $RM -f  ./.vcsmx_rebuild ./.vhdl_lib_lock
  $RM -f  ./.vlogansetup.args ./.vlogansetup.env
  $RM -fr ./urgReport ./DVEfiles
}

clean_mti () {
  $RM -f $ELOG $SLOG
  [ -d "$VLIBWORK" ] && $VDEL -lib $VLIBWORK -all
  $RM -f ./transcript ./vsim.wlf ./vsim.ucdb
}

clean_ius () {
  $RM -f $ELOG $SLOG
  $RM -f ncelab.err ncverilog.key
  $RM -fr ./INCA_libs
  $RM -fr ./wave.shm
}

clean_log () {
  $RM -f ./*.log
}

compile_vcs () {
  $VCS \
      $VLOGVER \
      ${RUN64:+-full64} \
      $COPTS \
      -debug_pp \
      ${TIMESCALE:+-timescale=$TIMESCALE} \
      ${DEFINE:++define$DEFINE} \
      ${LIBEXT:++libext$LIBEXT} \
      ${INCDIR:++incdir$INCDIR} \
      ${LIBDIR} ${VLOGARG} \
      -l $ELOG \
      $TESTS
}

compile_vcsmx () {
  [ -n "$VHDLARG" ] && \
  $VHDLAN \
      ${RUN64:+-full64} \
      ${VHDLARG} \
      -l $DLOG
  $VLOGAN \
      $VLOGVER \
      ${RUN64:+-full64} \
      $COPTS \
      ${TIMESCALE:+-timescale=$TIMESCALE} \
      ${DEFINE:++define$DEFINE} \
      ${LIBEXT:++libext$LIBEXT} \
      ${INCDIR:++incdir$INCDIR} \
      ${LIBDIR} ${VLOGARG} \
      -l $CLOG \
      $TESTS
  $VCS \
      ${RUN64:+-full64} \
      ${TIMESCALE:+-timescale=$TIMESCALE} \
      -debug_pp \
      -l $ELOG \
      $TOPS
}

compile_mti () {
  [ -n "$RUN64" ] && export MTI_VCO_MODE=64 || export MTI_VCO_MODE=32
  [ -d "$VLIBWORK" ] || $VLIB $VLIBWORK
  [ -f "$ELOG" ] && rm -f $ELOG

  [ -n "$VHDLARG" ] && \
  $VCOM \
      ${VHDLARG} \
      2>&1 | $TEE -a $ELOG
  $VLOG \
      $VLOGVER \
      $COPTS \
      ${TIMESCALE:+-timescale $TIMESCALE} \
      ${DEFINE:++define$DEFINE} \
      -lint \
      -mfcu \
      -nowarn 8 \
      +librescan \
      ${LIBEXT:++libext$LIBEXT} \
      ${INCDIR:++incdir$INCDIR} \
      ${LIBDIR} ${VLOGARG} \
      $TESTS \
      2>&1 | $TEE -a $ELOG
}

compile_ius () {
  $NCVERILOG \
      -elaborate \
      +access+r \
      $VLOGVER \
      ${RUN64:++nc64bit} \
      $COPTS \
      ${TIMESCALE:++nctimescale+$TIMESCALE} \
      ${DEFINE:++define$DEFINE} \
      ${LIBEXT:++libext$LIBEXT} \
      ${INCDIR:++incdir$INCDIR} \
      ${LIBDIR} ${VLOGARG} \
      -l $ELOG \
      $TESTS
}

if [ -x /bin/basename ]; then
  [ "`/bin/basename $0`" = "clean.sh" ] && CLEAN_ONLY=1
fi

### Read command line arguments
echo "$0 $*"
while [ $# -gt 0 ] ; do
  case "$1" in
    -vcs)
      TARGET="vcs";;
    -vcsi)
      VCS=vcsi; TARGET="vcs";;
    -vcsmx)
      TARGET="vcsmx";;
    -vcsmxi)
      VCS=vcsi; TARGET="vcsmx";;
    -mti)
      TARGET="mti";;
    -ius)
      TARGET="ius";;
    -all)
      TARGET="all";;
    -h|-help)
      TARGET="help";;
    -c|-clean)
      CLEAN_ONLY=1;;
    -l|-log)
      shift; ELOG=$1;;
    -d)
      shift; DEFINES="$DEFINES $1";;
    -o)
      shift; COPTS="$COPTS $1";;
    -fl)
      shift; VLOGARGS="$VLOGARGS $1";;
    -fc)
      shift; VHDLARGS="$VHDLARGS $1";;
    -t|-top)
      shift; TOPS="$TOPS $1";;
    -64)
      RUN64=1;;
    -32)
      RUN64=;;
    -v2k)
      VLOGVER=v2k;;
    -sv)
      VLOGVER=sv;;
    *)
      TESTS="$TESTS $1";;
  esac
  shift
done

DEFINE=
INCDIR=
LIBDIR=
LIBEXT=
VLOGARG=
VHDLARG=
for V in $DEFINES; do
  [ -z "$V" ] || DEFINE="${DEFINE}+${V}"
done
for V in $INCDIRS; do
  [ -z "$V" ] || INCDIR="${INCDIR}+${V}"
done
for V in $LIBDIRS; do
  [ -z "$V" ] || LIBDIR="${LIBDIR} -y ${V}"
done
for V in $LIBEXTS; do
  [ -z "$V" ] || LIBEXT="${LIBEXT}+${V}"
done
for V in $VLOGARGS; do
  [ -z "$V" ] || VLOGARG="${VLOGARG} -f ${V}"
done
for V in $VHDLARGS; do
  [ -z "$V" ] || VHDLARG="${VHDLARG} -f ${V}"
done
TARGET=${TARGET:-vcsmx}
CLOG=${CLOG:-compile-vlog-$TARGET.log}
DLOG=${DLOG:-compile-vhdl-$TARGET.log}
ELOG=${ELOG:-compile-$TARGET.log}
TOPS=${TOPS:-test}
VLOGVER=${VLOGVER:-sv}
SLOG="sim-$TARGET.log"

case "$TARGET" in
  vcs|VCS|vcsmx|VCSMX)
    [ $VLOGVER = "sv" ] && VLOGVER=-sverilog || VLOGVER=+v2k ;;
  mti|MTI)
    [ $VLOGVER = "sv" ] && VLOGVER=-sv || VLOGVER= ;;
  ius|IUS)
    [ $VLOGVER = "sv" ] && VLOGVER=+sv || VLOGVER= ;;
  help|HELP) help; exit 1;;
  *) echo "$TARGET: no such target"; exit 1;;
esac

case "$TARGET" in
  vcs|VCS|vcsmx|VCSMX) clean_vcs;;
  mti|MTI) clean_mti;;
  ius|IUS) clean_ius;;
  all|ALL) clean_vcs; clean_mti; clean_ius; clean_log;;
esac
[ $CLEAN_ONLY -ne 0 ] && exit 0

case "$TARGET" in
  vcs|VCS) compile_vcs;;
  vcsmx|VCSMX) compile_vcsmx;;
  mti|MTI) compile_mti;;
  ius|IUS) compile_ius;;
esac

exit 0
# end of file
