#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/inotify.h>

const char* BRIGHTNESS_FILE = "/sys/devices/platform/mtk_leds/leds/lcd-backlight/brightness";
const char* SCRIPT_SCREEN_ON = "/data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh";
const char* SCRIPT_SCREEN_OFF = "/data/adb/modules/BastionBattery/Kamui/KamuiPowersave.sh";

int read_brightness_value() {
    FILE *fp = fopen(BRIGHTNESS_FILE, "r");
    if (fp == NULL) {
        perror("Error opening brightness file");
        return -1;
    }

    int value = -1;
    if (fscanf(fp, "%d", &value) != 1) {
        fprintf(stderr, "Error reading integer from brightness file.\n");
        fclose(fp);
        return -1;
    }

    fclose(fp);
    return value;
}

void execute_script_for_state(int current_state, int *previous_state) {
    if (current_state != *previous_state) {
        if (current_state == 1) {
            printf("Screen ON. Executing KamuiBalanced.sh...\n");
            system(SCRIPT_SCREEN_ON);
        } else {
            printf("Screen OFF. Executing KamuiPowersave.sh...\n");
            system(SCRIPT_SCREEN_OFF);
        }
        *previous_state = current_state;
    }
}

int main() {
    int fd, wd;
    char buffer[4096] __attribute__ ((aligned(__alignof__(struct inotify_event))));
    int previous_state = -2;

    int initial_value = read_brightness_value();
    if (initial_value == -1) {
        fprintf(stderr, "Could not read initial brightness. Exiting.\n");
        return 1;
    }
    printf("Initial brightness value: %d\n", initial_value);
    int initial_state = (initial_value > 0) ? 1 : 0;
    execute_script_for_state(initial_state, &previous_state);

    fd = inotify_init1(IN_NONBLOCK);
    if (fd < 0) {
        perror("inotify_init1");
        return 1;
    }

    wd = inotify_add_watch(fd, BRIGHTNESS_FILE, IN_MODIFY);
    if (wd < 0) {
        fprintf(stderr, "Cannot watch '%s': %s\n", BRIGHTNESS_FILE, strerror(errno));
        close(fd);
        return 1;
    }

    printf("Kamui Auto Service started. Watching %s for changes...\n", BRIGHTNESS_FILE);

    while (1) {
        ssize_t len = read(fd, buffer, sizeof(buffer));
        if (len < 0) {
            if (errno == EAGAIN) {
                sleep(1);
                continue;
            }
            perror("read");
            break;
        }

        int current_value = read_brightness_value();
        if (current_value != -1) {
            int current_state = (current_value > 0) ? 1 : 0;
            execute_script_for_state(current_state, &previous_state);
        }
    }

    printf("Stopping Kamui Auto Service.\n");
    inotify_rm_watch(fd, wd);
    close(fd);

    return 0;
}
