#/usr/bin/env bash

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

# Avoid error dialog if OpenArena was force-closed previously.
rm -f /tmp/ioq3.pid

lscpu | grep "^CPU(s):"
glxinfo | grep -i "OpenGL version"
openarena +timedemo 1 +cg_drawfps 1 +quit 2>&1 | grep 'MODE'
echo ""

echo "Frames  TotalTime  averageFPS  minimum/average/maximum/std deviation"
echo ""

for I in {1..5} ; do
    perf record -o perf.data."$I" openarena +timedemo 1 +cg_drawfps 1 +demo demo088-test1.dm_71 +set nextdemo quit 2>&1 | grep 'frames'
    sleep 1s
done
