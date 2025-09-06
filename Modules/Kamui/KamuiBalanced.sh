#!/system/bin/sh

# Tweak function for LIFE Mode (locks freq by making files read-only)
tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
        chmod 444 "$2" >/dev/null 2>&1
    fi
}

# Tweak function for UNLOCK Mode (leaves files writable)
unlock_tweak() {
    if [ -e "$2" ]; then
        chmod 644 "$2" >/dev/null 2>&1
        echo "$1" > "$2" 2>/dev/null
    fi
}

# Finds the middle frequency from a list of available frequencies
which_midfreq() {
	total_opp=$(wc -w <"$1")
	mid_opp=$(((total_opp + 1) / 2))
	tr ' ' '\n' <"$1" | grep -v '^[[:space:]]*$' | sort -nr | head -n $mid_opp | tail -n 1
}

# Unlocks PPM CPU frequency limits to default min/max
cpufreq_ppm_unlock() {
	cluster=0
	for path in /sys/devices/system/cpu/cpufreq/policy*; do
		cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		unlock_tweak "$cluster $cpu_maxfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
		unlock_tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
		((cluster++))
	done
}

# Unlocks standard CPU frequency limits to default min/max
cpufreq_unlock() {
	for path in /sys/devices/system/cpu/*/cpufreq; do
		cpu_maxfreq=$(<"$path/cpuinfo_max_freq")
		cpu_minfreq=$(<"$path/cpuinfo_min_freq")
		unlock_tweak "$cpu_maxfreq" "$path/scaling_max_freq"
		unlock_tweak "$cpu_minfreq" "$path/scaling_min_freq"
	done
	chmod -f 644 /sys/devices/system/cpu/cpufreq/policy*/scaling_*_freq
}

#############################
# Read LIFE Mode Config
#############################
KAMUI_CONFIG="/data/adb/modules/BastionBattery/kamui.txt"
LIFE=$(grep '^LIFE=' "$KAMUI_CONFIG" | cut -d'=' -f2)

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
# Set CPU Freq (Normal or LIFE Mode)
#############################

if [ "$LIFE" -eq 1 ]; then
    # LIFE Mode is ON: Cap max CPU frequency to half
    
    # Apply to PPM if it exists
    if [ -d "/proc/ppm/policy" ]; then
        cluster=0
        for path in /sys/devices/system/cpu/cpufreq/policy*; do
            cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
            cpu_minfreq=$(<"$path/cpuinfo_min_freq")
            tweak "$cluster $cpu_midfreq" /proc/ppm/policy/hard_userlimit_max_cpu_freq
            tweak "$cluster $cpu_minfreq" /proc/ppm/policy/hard_userlimit_min_cpu_freq
            ((cluster++))
        done
    fi

    # Apply to standard scaling paths
    for path in /sys/devices/system/cpu/*/cpufreq; do
        cpu_midfreq=$(which_midfreq "$path/scaling_available_frequencies")
        cpu_minfreq=$(<"$path/cpuinfo_min_freq")
        tweak "$cpu_midfreq" "$path/scaling_max_freq"
        tweak "$cpu_minfreq" "$path/scaling_min_freq"
    done
else
    # LIFE Mode is OFF: Use normal balanced mode by unlocking frequencies
    
    if [ -d "/proc/ppm/policy" ]; then
        cpufreq_ppm_unlock
    else
        cpufreq_unlock
    fi
fi

#############################
# Power Save Mode Off
#############################
settings put global low_power 0