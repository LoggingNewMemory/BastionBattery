#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

const char* SCRIPT_SCREEN_ON = "/data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh";
const char* SCRIPT_SCREEN_OFF = "/data/adb/modules/BastionBattery/Kamui/KamuiPowersave.sh";

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
    int previous_state = -2;
    char buffer[64];

    while (1) {
        execute_cmd("cmd deviceidle get screen", buffer, sizeof(buffer));

        int current_state = 0; 
        if (strstr(buffer, "true") != NULL) {
            current_state = 1;
        }

        execute_script_for_state(current_state, &previous_state);

        sleep(2);
    }

    return 0;
}