# LMS UPnP Volume Bridge

**A plugin for Lyrion Music Server (LMS) to sync volume control with external UPnP devices (DACs, Amplifiers).**

This plugin bridges the gap between LMS's volume slider and high-end audio equipment that supports UPnP Rendering Control (e.g., PS Audio DirectStream, Denon/Marantz AVRs). It allows you to control the physical volume of your DAC using the LMS interface (Material Skin, iPeng, Squeezebox apps), preventing the need for separate remote controls or digital attenuation.

## Features

*   **Bi-directional Sync:**
    *   **LMS to DAC:** Moving the volume slider in LMS sends a UPnP `SetVolume` command to the device.
    *   **DAC to LMS:** Adjusting the physical knob on the DAC updates the LMS slider (via 1-second polling).
*   **Per-Player Configuration:** Enable/Disable sync for specific players.
*   **Custom IP/Port:** Support for devices on different subnets or non-standard UPnP ports.

---

## Installation

1.  Download this repository.
2.  Copy the `UPnPVolumeBridge` folder to your LMS Plugins directory:
    *   **Windows:** `C:\Program Files\Lyrion\server\Plugins\`
    *   **Linux/Docker:** `/var/lib/squeezeboxserver/Plugins/` (path varies by install)
3.  Restart Lyrion Music Server.
4.  Go to **Settings** -> **Plugins** and ensure **UPnP Volume Bridge** is active.

---

## Configuration

1.  Navigate to **Settings** -> **Plugins** -> **UPnP Volume Bridge** settings page.
2.  You will see a list of your connected players.
3.  **Enabled:** Check to activate the bridge for this player.
4.  **Bridge IP Address:** Enter the IP address of your UPnP DAC/Amp.
5.  **Bridge Port:** Enter the UPnP control port (Default is usually `38400` or `8080`, check your device documentation).
6.  **Sync:** Check to enable bi-directional polling (reads volume FROM the device).

---

## 🎧 Bit-Perfect Volume Control (The "Dummy Player" Method)

By default, LMS attenuates the audio signal digitally when you lower the volume. If your DAC supports remote volume control, you probably want to send a **100% bit-perfect stream** to the DAC and let the DAC handle the volume in it's own digital domain.

To achieve this **without** LMS constantly fighting the volume slider, use the **Dummy Player** strategy:

### Step 1: Create a Dummy Player
You need a secondary "virtual" player in LMS that controls the volume, while your real player stays fixed at 100%.

*   **Option A (Squeezelite):** Run a second instance of Squeezelite on your server/PC.
    *   Command: `squeezelite -n "Volume Control" -o dummy` (or use an unused audio output).
*   **Option B (Extra Player):** Use an old Squeezebox or Radio that is synced but muted/not connected to speakers.

### Step 2: Configure LMS Sync
1.  In LMS, create a **Sync Group**.
2.  Group your **Real Player** (connected to the DAC) and your **Dummy Player**.
3.  **Important:** Configure your **Real Player** to "Fixed Volume (100%)" or "Digital Output Always On" in its own Player Settings (Audio -> Volume Control).
    *   This ensures the Real Player *always* outputs 100% signal, regardless of what the sync group slider says.

### Step 3: Configure the Plugin
1.  In the **UPnP Volume Bridge** settings:
2.  Find the **Dummy Player** in the list.
3.  **Enable** it and enter your DAC's IP address.
4.  Do **NOT** enable the plugin for the Real Player.

### How it works:
1.  You adjust the volume on the **Dummy Player** (via App/Web).
2.  Lyrion updates the visual slider for the group.
3.  **The Plugin** sees the Dummy Player change and sends the UPnP command to your physical DAC.
4.  **The Real Player** ignores the volume change (because it's set to Fixed 100%) and keeps streaming bit-perfect audio.
5.  Your DAC adjusts the volume digitally.

Enjoy the best of both worlds: Digital perfection and convenient App control!
