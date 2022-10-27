#/usr/bin/env bash

ls furmark-v2.trace 2>&1 >/dev/null || wget "https://minio-packet.freedesktop.org/mesa-tracie-public/gputest/furmark-v2.trace"

apitrace --help 2>&1 >/dev/null || echo "You need to install apitrace!  Try: sudo apt install apitrace"
apitrace --help 2>&1 >/dev/null || exit -1

export LIBGL_ALWAYS_SOFTWARE=true
export GALLIUM_DRIVER=llvmpipe

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

for I in {1..5} ; do
    perf record -o perf.data."$I" apitrace replay --benchmark --headless --loop=60 furmark-v2.trace 2>&1 | grep 'fps'
    sleep 1s
done

for I in {1..5} ; do
    echo "Generating perf report $I..."
    perf report -i perf.data."$I" | grep -v ' 0\.00%' > perf.report."$I".txt
done

echo "Your perf reports have been generated."
