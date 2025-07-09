#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>

#define BUFFER_SIZE 1024
#define KAMUI_BALANCED "/data/adb/modules/BastionBattery/Kamui/KamuiBalanced.sh"
#define KAMUI_POWERSAVE "/data/adb/modules/BastionBattery/Kamui/KamuiPowersave.sh"

int main(void) {
    bool prev_screen_on = true; // Assume screen is on initially

    while (1) {
        // Get Screen On / Off status
        bool current_screen_on = true;
        FILE *screen_pipe = popen("dumpsys window | grep \"mScreenOn\" | grep false", "r");
        if (screen_pipe) {
            char screen_buffer[BUFFER_SIZE];
            if (fgets(screen_buffer, sizeof(screen_buffer), screen_pipe)) {
                current_screen_on = false;
            }
            pclose(screen_pipe);
        }    

        // Only execute when screen state changes (avoid multiple executions)
        if (current_screen_on != prev_screen_on) {
            if (current_screen_on) {
                // Screen turned ON -> execute Balanced
                char command[BUFFER_SIZE];
                snprintf(command, sizeof(command), "sh %s", KAMUI_BALANCED);
                system(command);
            }
            else if (!current_screen_on) {  // FIXED: was (current_screen_on)
                // Screen turned OFF -> execute Powersave
                char command[BUFFER_SIZE];
                snprintf(command, sizeof(command), "sh %s", KAMUI_POWERSAVE);
                system(command);
            }
            prev_screen_on = current_screen_on;
        }

        sleep(10); // 10 second interval
    }
}