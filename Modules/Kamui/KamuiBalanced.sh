tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

#############################
# Set Governor To Schedhorizon / Schedutil
#############################

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

#############################
# Set CPU Freq to Normal
#############################

cluster=0
	for path in /sys/devices/system/cpu/cpufreq/policy*; do
		cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cluster $cpu_maxfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
		((cluster++))
	done

for path in /sys/devices/system/cpu/*/cpufreq; do
		cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cpu_maxfreq" "$path/scaling_max_freq"
		tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	chmod -f 644 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq

#############################
# Power Save Mode Off
#############################
settings put global low_power 0