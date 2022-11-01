#/usr/bin/env bash

apitrace --help 2>&1 >/dev/null || echo "You need to install apitrace!  Try: sudo apt install apitrace"
apitrace --help 2>&1 >/dev/null || exit -1

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

echo "Benchmarks should take around 4 hours to run, be patient!"
echo ""

lscpu | grep "^CPU(s):"
echo "Memory:"
lshw -class memory | grep "          size" || exit -1
glxinfo | grep -i "OpenGL version"
glxgears > /dev/null &
sleep 5s
echo "LP_MAX_THREADS: $(ps H -o 'tid comm' $(ps -e | grep glxgears | cut -f 1 -d ' ') | grep -i llvmpipe | wc -l)"
killall glxgears
sleep 5s
echo ""

# All publicly documented Sforza core counts, in single and double CPU configurations.
# Also test 8 threads (not a Sforza core count) for comparison purposes.
for THREADS in 8 16 32 48 64 72 80 88 96 128 144 160 176 ; do
    echo "$THREADS Threads:"
    export LP_NUM_THREADS="$THREADS"
    for I in {1..5} ; do
        apitrace replay --benchmark --headless openarena.trace 2>&1 | grep 'fps'
        sleep 1s
    done
    echo ""
done
