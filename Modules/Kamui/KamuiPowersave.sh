tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

# Switch to powersave
for path in /sys/devices/system/cpu/cpufreq/policy*; do
	tweak powersave $path/scaling_governor
done 