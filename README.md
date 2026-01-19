ms-employeelist 🎧
A Sleek, Tactical Online Employee List UI for FiveM (QBCore & ESX)

ms-employeelist is a modern, performance-optimized UI replacement for standard job lists. Designed with a futuristic/tactical aesthetic, it allows police, EMS, and other whitelist jobs to view online colleagues, radio channels, and duty status in real-time.

It features a HUD Mode that stays on screen during gameplay, with fully customizable positioning, scaling, and opacity that saves locally for every player.

✨ Key Features
🎨 Tactical Design: A clean, sci-fi inspired interface (9:16 aspect ratio) with glowing borders and a tactical font.

💾 Persistent Customization:

UI Settings: Players can Drag, Scale, and change Opacity. These settings are saved to Local Storage and remember their position after restarts.

Player Data: Editable Call Signs and Names are saved to a server-side JSON file, persisting through server restarts without database SQL queries.

🚦 Live Status System:

Green: On Duty

Red: Off Duty

Yellow: Break / AFK (Custom toggle in settings)

📻 Radio Integration: Automatically pulls current radio channels (requires pma-voice).

⌨️ Smart Interaction:

Edit Mode: Type /elist to unlock the mouse, move the UI, and edit your details.

HUD Mode: Click the ✔ button to lock the UI in place and return to gameplay while keeping the list visible.

Keyboard Support: Use Arrow Keys to fine-tune Scale and Opacity sliders.

🔒 Secured Access: Restricted to configured jobs only (Police, Ambulance, etc.).

⚡ Optimized Performance: Runs at 0.00ms idle. Only consumes resources when the UI is actually open.

📷 Preview
(Add your screenshots or GIFs here)

📥 Installation
Download the ms-employeelist folder.

Drop it into your server's resources directory.

Add ensure ms-employeelist to your server.cfg.

Dependencies:

qb-core OR es_extended (Legacy or latest)

pma-voice (For radio channel syncing)

⚙️ Configuration
config.lua is simple and allows you to bridge the script to your framework easily.

Lua

Config = {}

-- Select Framework: 'qbcore' or 'esx'
Config.Framework = 'qbcore' 

-- Jobs authorized to use the command
Config.AllowedJobs = {
    ['police'] = true,
    ['ambulance'] = true,
    ['mechanic'] = true
}

-- Command to open the menu
Config.Command = 'elist'
🎮 Usage Guide
1. Opening the List

Type /elist to open the UI in Edit Mode.

In this mode, you can drag the window, change settings, or edit your Name/Callsign.

2. Going on Break

Open Edit Mode (/elist).

In the top settings bar, click BREAK.

Your status will turn Yellow for everyone else, indicating you are unavailable.

3. Locking to HUD

Once you are happy with the position and scale, click the ✔ (Confirm) button in the settings bar.

The settings bar will disappear, the mouse will vanish, and the list will remain on your screen as a HUD element.

4. Closing

To close the UI completely, type /elist again (or press ESC while in Edit Mode).

🛠️ Developer Notes
Data Storage: Player names and callsigns are stored in custom_data.json within the resource folder. Do not delete this file if you want to keep player edits.

CSS Customization: All colors are defined in html/style.css under the :root variables, making it easy to re-theme for different departments.

🤝 Contributing
Feel free to fork this repository and submit pull requests. Suggestions and feature requests are welcome!

### ⚖️ License
This project is licensed under the [MIT License](LICENSE).
