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

# Finds the middle available frequency for a given policy
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
		if [ "$LIFE" -eq 1 ]; then
			# LIFE Mode (Enabled): Cap max freq to mid freq for power saving
			cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
			tweak "$cluster $cpu_midfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		else
			# Normal Mode (Disabled): Set max freq to the highest possible
			cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
			tweak "$cluster $cpu_maxfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		fi

		# For both modes, the min freq is set to the absolute lowest
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
	done
}

# Sets CPU frequencies using standard sysfs nodes
cpufreq() {
	for path in /sys/devices/system/cpu/*/cpufreq; do
		if [ "$LIFE" -eq 1 ]; then
			# LIFE Mode (Enabled): Cap max freq to mid freq for power saving
			cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
			tweak "$cpu_midfreq" "$path/scaling_max_freq"
		else
			# Normal Mode (Disabled): Set max freq to the highest possible
			cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
			tweak "$cpu_maxfreq" "$path/scaling_max_freq"
		fi

		# For both modes, the min freq is set to the absolute lowest
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	# Ensure frequency nodes are read-only
	chmod -f 444 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq
}

#############################
# Set CPU Freq based on LIFE mode
#############################

# Read LIFE mode setting (1 for enabled, 0 for disabled)
LIFE=$(cat /data/adb/modules/BastionBattery/Kamui.txt)

# Check for Mediatek PowerHAL (PPM) to use the appropriate method
if [ -d /proc/ppm ]; then
    cpufreq_ppm
else
    cpufreq
fi