#/usr/bin/env bash

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

# Avoid error dialog if OpenArena was force-closed previously.
rm -f /tmp/ioq3.pid

lscpu | grep "^CPU(s):"
echo "Memory:"
lshw -class memory | grep "          size" || exit -1
glxinfo | grep -i "OpenGL version"
glxgears > /dev/null &
sleep 5s
echo "LP_MAX_THREADS: $(ps H -o 'tid comm' $(ps -e | grep glxgears | cut -f 1 -d ' ') | grep -i llvmpipe | wc -l)"
killall glxgears
sleep 5s
openarena +timedemo 1 +cg_drawfps 1 +quit 2>&1 | grep 'MODE'
echo ""

# Work around "HUNK_ALLOC FAILED" error with default OpenArena settings
sed -i 's/seta com_hunkMegs "[0-9]*"/seta com_hunkMegs "256"/' ~/.openarena/baseoa/q3config.cfg

echo "Frames  TotalTime  averageFPS  minimum/average/maximum/std deviation"
echo ""

for I in {1..5} ; do
    # Avoid error dialog if OpenArena was force-closed previously.
    rm -f /tmp/ioq3.pid

    perf record -o perf.data."$I" openarena +timedemo 1 +cg_drawfps 1 +demo demo088-test1.dm_71 +set nextdemo quit 2>&1 | grep 'frames'
    sleep 1s
done

for I in {1..5} ; do
    echo "Generating perf report $I..."
    perf report -i perf.data."$I" | grep -v ' 0\.00%' > perf.report."$I".txt
done

echo "Your perf reports have been generated."
