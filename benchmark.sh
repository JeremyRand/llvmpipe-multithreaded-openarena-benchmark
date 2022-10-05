#/usr/bin/env bash

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

# Avoid error dialog if OpenArena was force-closed previously.
rm -f /tmp/ioq3.pid

echo "Benchmarks should take around 4 hours to run, be patient!"
echo ""

lscpu | grep "^CPU(s):"
glxinfo | grep -i "OpenGL version"
openarena +timedemo 1 +cg_drawfps 1 +quit 2>&1 | grep 'MODE'
echo ""

echo "Frames  TotalTime  averageFPS  minimum/average/maximum/std deviation"
echo ""

# All publicly documented Sforza core counts, in single and double CPU configurations.
for THREADS in 16 32 48 64 72 80 88 96 128 144 160 176 ; do
    echo "$THREADS Threads:"
    export LP_NUM_THREADS="$THREADS"
    for I in {1..5} ; do
        openarena +timedemo 1 +cg_drawfps 1 +demo demo088-test1.dm_71 +set nextdemo quit 2>&1 | grep 'frames'
    done
    echo ""
done
