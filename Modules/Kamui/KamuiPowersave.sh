#!/system/bin/sh

# Tweak function to safely write values to system files
tweak() {
    if [ -e "$2" ]; then
        # Set permissions to read-write for owner, read-only for others
        chmod 644 "$2" >/dev/null 2>&1
        # Write the value to the file
        echo "$1" > "$2" 2>/dev/null
        # Set permissions to read-only for all to prevent unintended changes
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

#############################
# Helper functions
#############################

# Finds the middle available frequency for a given CPU policy.
# This is used to cap the CPU frequency for power saving.
which_midfreq() {
	total_opp=$(wc -w <"$1")
	mid_opp=$(((total_opp + 1) / 2))
	tr ' ' '\n' <"$1" | grep -v '^[[:space:]]*$' | sort -nr | head -n "$mid_opp" | tail -n 1
}

# Sets CPU frequencies for Mediatek PowerHAL (PPM)
cpufreq_ppm() {
	cluster=-1
	for path in /sys/devices/system/cpu/cpufreq/policy*; do
		((cluster++))
		cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
		tweak "$cluster $cpu_midfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
	done
}

cpufreq() {
	for path in /sys/devices/system/cpu/*/cpufreq; do
		cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
		tweak "$cpu_midfreq" "$path/scaling_max_freq"
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	chmod -f 444 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq
}

#############################
# Set CPU Freq to Mid-Freq
#############################

# Check for Mediatek PowerHAL (PPM) to use the appropriate method
if [ -d /proc/ppm ]; then
    cpufreq_ppm
else
    cpufreq
fi