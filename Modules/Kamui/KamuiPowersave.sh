#!/system/bin/sh

tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

#############################
# CPU Powersave Functions
#############################

# Sets PPM CPU frequency limits to minimum for powersave
cpufreq_ppm_min_perf() {
    cluster=-1
    for path in /sys/devices/system/cpu/cpufreq/policy*; do
        ((cluster++))
        local cpu_minfreq
        cpu_minfreq=$(<"$path/cpuinfo_min_freq")
        tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
        tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
    done
}

# Sets standard CPU frequency limits to minimum for powersave
cpufreq_min_perf() {
    for path in /sys/devices/system/cpu/*/cpufreq; do
        local cpu_minfreq
        cpu_minfreq=$(<"$path/cpuinfo_min_freq")
        tweak "$cpu_minfreq" "$path/scaling_max_freq"
        tweak "$cpu_minfreq" "$path/scaling_min_freq"
    done
    chmod -f 444 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq
}

#############################
# Set Governor To Minimum
#############################

# Switch to powersave governor
for path in /sys/devices/system/cpu/cpufreq/policy*; do
	tweak powersave "$path/scaling_governor"
done 

#############################
# Set CPU Freq to Minimum
#############################

# Check if PPM exists and apply the correct frequency setting method
if [ -d "/proc/ppm/policy" ]; then
    cpufreq_ppm_min_perf
else
    cpufreq_min_perf
fi

#############################
# Power Save Mode On
#############################
settings put global low_power 1