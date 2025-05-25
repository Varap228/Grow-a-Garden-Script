# Grow-a-Garden Script

A simple Lua script to help automate tasks in the Roblox game "Grow-a-Garden". This script provides a user interface to manage auto-planting seeds and auto-collecting fruits.

## How to Use

To use this script, you'll need a Roblox script executor.
Copy and paste the following line into your executor:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/Varap228/Grow-a-Garden-Script/refs/heads/main/source.lua'))()
```

## Features

The script provides a UI with two main tabs: "Main" and "Settings".

### Main Tab

*   **Set Plant Position**:
    *   Sets the spot where seeds will be planted. It uses your character's current position.
*   **Seed Selection**:
    *   A dropdown to choose which type of seed you want to plant.
*   **Auto Plant**:
    *   A toggle to turn automatic seed planting on or off. When on, it will plant the selected seed at the set position.
*   **Auto Collect**:
    *   A toggle to turn automatic fruit collection on or off. When on, it will collect ripe fruits from your plants.

### Settings Tab

*   **Auto Buy Seeds**:
    *   If enabled, the script will try to buy more of the selected seed if you run out.
*   **Use Distance Check**:
    *   If enabled, the script will only collect fruits that are within a certain range of your character. This can sometimes affect performance.
*   **Collect Nearest Fruit**:
    *   If "Use Distance Check" is on, this option makes the script prioritize collecting the fruit closest to you.
*   **Collection Distance**:
    *   A slider to set how far away the script should look for fruits to collect (only if "Use Distance Check" is on).
*   **Debug Mode**:
    *   If enabled, the script will print extra information to the developer console (useful for troubleshooting).

## Future Plans

I'm planning to add the following features in future updates:

*   **Auto Farm**: More comprehensive automation for managing the entire farm.
*   **Auto Sell**: Automatically sell collected produce.

## Credits

*   **Script Author**: varap228 (Discord: varap228)
*   **UI Library**: WindUI by Footagesus
*   **Notification Library**: Jxereas

---

Enjoy gardening!
