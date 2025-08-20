tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

#############################
# Set Governor To Minimum
#############################

# Switch to powersave
for path in /sys/devices/system/cpu/cpufreq/policy*; do
	tweak powersave $path/scaling_governor
done 

#############################
# Set CPU Freq to Min
#############################

cluster=-1
	for path in /sys/devices/system/cpu/cpufreq/policy*; do
		((cluster++))
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
	done

for path in /sys/devices/system/cpu/*/cpufreq; do
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		tweak "$cpu_minfreq" "$path/scaling_max_freq"
		tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	chmod -f 444 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq

#############################
# Power Save Mode On
#############################
settings put global low_power 1