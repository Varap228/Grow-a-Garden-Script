# Grow-a-Garden Script

A utility script to automate and enhance your gardening experience in Roblox "Grow-a-Garden" games.

## Features

*   **Automated Planting:**
    *   Select a seed type from a dropdown list.
    *   Set a custom planting position or use the farm's default.
    *   Automatically plants the chosen seed at the specified location.
    *   Option to automatically buy more seeds if you run out.
*   **Automated Fruit Collection:**
    *   Automatically harvests ripe fruits/vegetables from your farm.
    *   **Smart Collection Options:**
        *   `Collect Nearest Fruit`: Prioritizes collecting the fruit closest to your player.
        *   `Use Distance Check`: Only collects fruits within a specified range.
        *   `Collection Distance`: Slider to adjust the radius for distance-based collection.
*   **User-Friendly GUI:**
    *   Clean interface powered by WindUI for easy control.
    *   Separate "Main" and "Settings" tabs for organized functionality.
    *   Theme switching for a personalized look.
*   **Notifications:** Provides in-game notifications for script actions and status.
*   **Debug Mode:** Optional console logging for troubleshooting or seeing what the script is doing.

## How to Use

Execute the following script using your preferred Roblox script executor:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/Varap228/Grow-a-Garden-Script/refs/heads/main/source.lua'))()
```

## GUI Overview

### Main Tab:

*   **Set Plant Position:** Click to set your current character's position as the target for auto-planting.
*   **Seed Selection:** Choose the type of seed you want to auto-plant from a list.
*   **Auto Plant (Toggle):** Start/stop automatic seed planting.
*   **Auto Collect (Toggle):** Start/stop automatic fruit collection.

### Settings Tab:

*   **Auto Buy Seeds (Toggle):** If enabled, the script will try to buy more seeds when you run out of the selected type.
*   **Use Distance Check (Toggle):** If enabled, auto-collection will only target fruits within the "Collection Distance".
*   **Collect Nearest Fruit (Toggle):** If enabled (and distance check is on), the script will collect the single closest fruit first before checking others.
*   **Collection Distance (Slider):** Adjust how far the script will look for fruits to collect.
*   **Debug Mode (Toggle):** Outputs additional information to the developer console for debugging.

