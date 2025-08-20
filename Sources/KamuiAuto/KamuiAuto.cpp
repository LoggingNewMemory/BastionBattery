#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/inotify.h>
#include <ctype.h>

// --- Potential Brightness File Paths ---
const char* SNAPDRAGON_PATH = "/sys/devices/platform/soc/ae00000.qcom,mdss_mdp/backlight/panel0-backlight/brightness";
const char* MEDIATEK_PATH = "/sys/devices/platform/mtk_leds/leds/lcd-backlight/brightness";

// --- Global Variable for the Detected Path ---
const char* BRIGHTNESS_FILE = NULL;

// --- Scripts to execute ---
const char* SCRIPT_SCREEN_ON = "/data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh";
const char* SCRIPT_SCREEN_OFF = "/data/adb/modules/BastionBattery/Kamui/KamuiPowersave.sh";

// --- CPU Vendor Detection Logic ---

void execute_cmd(const char* cmd, char* result, size_t size) {
    FILE *pipe = popen(cmd, "r");
    if (!pipe) {
        strncpy(result, "", size);
        return;
    }
    if (fgets(result, size, pipe) != NULL) {
        result[strcspn(result, "\n")] = 0;
    } else {
        strncpy(result, "", size);
    }
    pclose(pipe);
}

void to_lower(char *str) {
    for (int i = 0; str[i]; i++) {
        str[i] = tolower(str[i]);
    }
}

int get_cpu_vendor() {
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (fp != NULL) {
        char line[256];
        while (fgets(line, sizeof(line), fp)) {
            if (strstr(line, "Hardware") != NULL || strstr(line, "Processor") != NULL) {
                to_lower(line);
                if (strstr(line, "qcom") != NULL || strstr(line, "qualcomm") != NULL || strstr(line, "sm")) {
                    fclose(fp);
                    return 1; // Snapdragon
                }
                if (strstr(line, "mt") != NULL || strstr(line, "mediatek") != NULL) {
                    fclose(fp);
                    return 2; // MediaTek
                }
            }
        }
        fclose(fp);
    }

    char prop_value[256];
    
    execute_cmd("getprop ro.board.platform", prop_value, sizeof(prop_value));
    to_lower(prop_value);
    if (strstr(prop_value, "qcom") != NULL || strstr(prop_value, "sm")) {
        return 1; // Snapdragon
    }
    if (strstr(prop_value, "mt")) {
        return 2; // MediaTek
    }

    execute_cmd("getprop ro.hardware", prop_value, sizeof(prop_value));
    to_lower(prop_value);
    if (strstr(prop_value, "qcom") != NULL || strstr(prop_value, "qualcomm") != NULL) {
        return 1; // Snapdragon
    }
     if (strstr(prop_value, "mt") != NULL || strstr(prop_value, "mediatek") != NULL) {
        return 2; // MediaTek
    }

    return 0; // Unknown
}


void find_brightness_file() {
    int vendor = get_cpu_vendor();
    
    if (vendor == 1) {
        BRIGHTNESS_FILE = SNAPDRAGON_PATH;
    } else if (vendor == 2) {
        BRIGHTNESS_FILE = MEDIATEK_PATH;
    } else {
        BRIGHTNESS_FILE = NULL;
    }
}

int read_brightness_value() {
    FILE *fp = fopen(BRIGHTNESS_FILE, "r");
    if (fp == NULL) {
        return -1;
    }

    int value = -1;
    if (fscanf(fp, "%d", &value) != 1) {
        fclose(fp);
        return -1;
    }

    fclose(fp);
    return value;
}

void execute_script_for_state(int current_state, int *previous_state) {
    if (current_state != *previous_state) {
        if (current_state == 1) {
            system(SCRIPT_SCREEN_ON);
        } else {
            system(SCRIPT_SCREEN_OFF);
        }
        *previous_state = current_state;
    }
}

int main() {
    find_brightness_file();
    if (BRIGHTNESS_FILE == NULL) {
        return 1;
    }

    int fd, wd;
    char buffer[4096] __attribute__ ((aligned(__alignof__(struct inotify_event))));
    int previous_state = -2;

    int initial_value = read_brightness_value();
    if (initial_value == -1) {
        return 1;
    }
    int initial_state = (initial_value > 0) ? 1 : 0;
    execute_script_for_state(initial_state, &previous_state);

    fd = inotify_init1(IN_NONBLOCK);
    if (fd < 0) {
        return 1;
    }

    wd = inotify_add_watch(fd, BRIGHTNESS_FILE, IN_MODIFY);
    if (wd < 0) {
        close(fd);
        return 1;
    }

    while (1) {
        ssize_t len = read(fd, buffer, sizeof(buffer));
        if (len < 0) {
            if (errno == EAGAIN) {
                sleep(1);
                continue;
            }
            break;
        }

        int current_value = read_brightness_value();
        if (current_value != -1) {
            int current_state = (current_value > 0) ? 1 : 0;
            execute_script_for_state(current_state, &previous_state);
        }
    }

    inotify_rm_watch(fd, wd);
    close(fd);

    return 0;
}
