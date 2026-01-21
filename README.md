Lyrion UPnP Volume Bridge

A plugin for Lyrion Music Server (formerly Logitech Media Server) that synchronizes player volume and mute states with external UPnP/DLNA rendering devices.

This is particularly useful when using a Lyrion player (like a Raspberry Pi with squeezelite) as a source for an external amplifier or active speakers that support UPnP volume control.

Features

Volume Sync: Automatically forwards volume changes from the Lyrion UI/App to the external device.

Mute Sync: Supports mirroring mute/unmute states.

Per-Player Configuration: Configure different UPnP targets for each Lyrion player.

Async Execution: Uses non-blocking HTTP requests to ensure server stability.

Installation

Method 1: Via Lyrion Repository (Recommended)

You can add this GitHub repository directly to Lyrion to handle installations and updates automatically:

Open the Lyrion Web Interface.

Go to Settings > Plugins.

At the bottom of the page, look for Additional Repositories.

Add the following URL:
https://raw.githubusercontent.com/Mojopriest88/UPnPVolumeBridge/main/repo.xml

Click Apply.

Find UPnP Volume Bridge in the plugin list, check the box, and click Apply at the bottom right.

Method 2: Manual Installation

Download the source code as a ZIP file.

Create a folder named UPnPVolumeBridge in your Lyrion Plugins directory.

Extract the files into that directory.

Restart Lyrion Music Server.

Enable the plugin in Settings > Plugins.

Configuration

Navigate to Player Settings.

Select your player from the dropdown.

Select UPnP Volume Bridge from the settings menu.

Enable the bridge and provide the UPnP Control URL.

Finding the Control URL

The URL usually points to the RenderingControl service. You can find this using a UPnP inspector tool (like "Device Spy" or "UPnP Tool"). It typically looks like:
http://<IP_ADDRESS>:<PORT>/MediaRenderer/RenderingControl/Control

Requirements

Lyrion / LMS 8.0+

A UPnP device supporting RenderingControl:1

License

MIT
