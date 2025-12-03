#!/system/bin/sh

tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

which_midfreq() {
	total_opp=$(wc -w <"$1")
	mid_opp=$(((total_opp + 1) / 2))
	tr ' ' '\n' <"$1" | grep -v '^[[:space:]]*$' | sort -nr | head -n "$mid_opp" | tail -n 1
}

cpufreq_ppm() {
	cluster=-1
	for path in /sys/devices/system/cpu/cpufreq/policy*; do
		((cluster++))
		if [ "$LIFE" -eq 1 ]; then
			cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
			tweak "$cluster $cpu_midfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		else
			cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
			tweak "$cluster $cpu_maxfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		fi

		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
	done
}

cpufreq() {
	for path in /sys/devices/system/cpu/*/cpufreq; do
		if [ "$LIFE" -eq 1 ]; then
			cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
			tweak "$cpu_midfreq" "$path/scaling_max_freq"
		else
			cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
			tweak "$cpu_maxfreq" "$path/scaling_max_freq"
		fi

		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	chmod -f 444 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq
}

LIFE=$(cat /data/adb/modules/BastionBattery/Kamui.txt)

if [ -d /proc/ppm ]; then
    cpufreq_ppm
fi
cpufreq