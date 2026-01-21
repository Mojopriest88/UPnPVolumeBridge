# UPnPVolumeBridge
A plugin for Lyrion Music Server that syncs Lyrion player volume with an external UPnP/DLNA renderer.

Lyrion UPnP Volume Bridge

A plugin for Lyrion Music Server (formerly Logitech Media Server) that synchronizes player volume and mute states with external UPnP/DLNA rendering devices.

This is particularly useful when using a Lyrion player (like a Raspberry Pi with squeezelite) as a source for an external amplifier or active speakers that support UPnP volume control.

Features

Volume Sync: Automatically forwards volume changes from the Lyrion UI/App to the external device.

Mute Sync: Supports mirroring mute/unmute states.

Per-Player Configuration: Configure different UPnP targets for each Lyrion player.

Async Execution: Uses non-blocking HTTP requests to ensure server stability.

Installation

Create a folder named UPnPVolumeBridge in your Lyrion Plugins directory.

Clone or copy these files into that directory.

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
