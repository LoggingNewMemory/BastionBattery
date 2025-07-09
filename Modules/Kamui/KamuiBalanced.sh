tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

check_governor() {
    local governor="$1"
    local available_governors="$2"
    echo "$available_governors" | grep -q "$governor"
}

for path in /sys/devices/system/cpu/cpufreq/policy*; do
    if [ -e "$path/scaling_available_governors" ]; then
        available_governors=$(cat "$path/scaling_available_governors")
        
        if check_governor "schedhorizon" "$available_governors"; then
            tweak schedhorizon "$path/scaling_governor"
        elif check_governor "schedutil" "$available_governors"; then
            tweak schedutil "$path/scaling_governor"
        fi
    fi
done