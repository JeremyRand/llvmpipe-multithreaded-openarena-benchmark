#/usr/bin/env bash

apitrace --help 2>&1 >/dev/null || echo "You need to install apitrace!  Try: sudo apt install apitrace"
apitrace --help 2>&1 >/dev/null || exit -1

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

# Avoid error dialog if OpenArena was force-closed previously.
rm -f /tmp/ioq3.pid

# Work around "HUNK_ALLOC FAILED" error with default OpenArena settings
sed -i 's/seta com_hunkMegs "[0-9]*"/seta com_hunkMegs "256"/' ~/.openarena/baseoa/q3config.cfg

echo "Frames  TotalTime  averageFPS  minimum/average/maximum/std deviation"
echo ""

# Avoid error dialog if OpenArena was force-closed previously.
rm -f /tmp/ioq3.pid

apitrace trace openarena +timedemo 1 +cg_drawfps 1 +demo demo088-test1.dm_71 +set nextdemo quit 2>&1 | grep 'frames'

mv quake3.trace openarena.trace

echo "Trace has been written!"
