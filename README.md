# Grow-a-Garden Script V1.2

An enhanced Lua script to automate common tasks in Roblox "Grow-a-Garden" style games. This script provides a user-friendly interface to manage auto-planting seeds, auto-collecting fruits, and now, auto-selling your produce!

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
    *   Sets your character's current position as the target spot for automatic seed planting.
*   **Seed Selection**:
    *   A dropdown menu to choose the type of seed you want the script to plant.
*   **Auto Plant (Toggle)**:
    *   Turns automatic seed planting on or off. If enabled, it plants the selected seed at the set position.
*   **Auto Collect (Toggle)**:
    *   Turns automatic fruit collection on or off. If enabled, it gathers ripe fruits from your farm.
*   **Auto Sell (Toggle)**:
    *   Turns automatic selling of your inventory on or off. When enabled, the script will teleport to the sell point and sell your items based on the chosen method.
*   **Auto-Sell Method (Dropdown)**:
    *   Choose how the script decides when to sell:
        *   `Check notification`: Sells when the "Max backpack space!" game notification appears.
        *   `Check backpack (200 items)`: Sells when your backpack reaches 200 holdable items.

### Settings Tab

*   **Auto Buy Seeds (Toggle)**:
    *   If enabled, the script will automatically attempt to purchase more of the selected seed type if you run out.
*   **Use Distance Check (Collect) (Toggle)**:
    *   If enabled, auto-collection will only target fruits within the specified "Collection Distance". This might slightly impact performance.
*   **Collect Nearest Fruit First (Toggle)**:
    *   If "Use Distance Check" is active, this option makes the script prioritize collecting the fruit closest to your character first.
*   **Collection Distance (Slider)**:
    *   Adjusts the maximum range (in studs) within which the script will look for fruits to collect (active only if "Use Distance Check" is on).
*   **Debug Mode (Toggle)**:
    *   If enabled, the script will print additional information and actions to the developer console, which can be helpful for troubleshooting.
   
## Planned
   auto farm

## Credits

*   **Script Author**: Varap228 (Discord: varap228)
*   **UI Library**: WindUI by Footagesus
*   **Notification Library**: Jxereas

---

Enjoy your automated and efficient gardening!
