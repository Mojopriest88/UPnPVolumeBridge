use strict;
use warnings;

my $file = "C:\\Program Files\\Lyrion\\server\\Plugins\\UPnPVolumeBridge\\strings.txt";

open(my $fh, '>', $file) or die "Could not open file '$file' $!";
binmode($fh);

print $fh "PLUGIN_UPNPVOLUMEBRIDGE\n";
print $fh "\tEN\tUPnP Volume Bridge\n";
print $fh "\tNL\tUPnP Volume Bridge\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_SETTINGS_TITLE\n";
print $fh "\tEN\tUPnP Volume Bridge Settings\n";
print $fh "\tNL\tUPnP Volume Bridge Instellingen\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_DESCRIPTION\n";
print $fh "\tEN\tForward volume control to external UPnP devices.\n";
print $fh "\tNL\tStuur volume bediening door naar externe UPnP apparaten.\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_PLAYER\n";
print $fh "\tEN\tPlayer\n";
print $fh "\tNL\tSpeler\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_ENABLED\n";
print $fh "\tEN\tEnabled\n";
print $fh "\tNL\tIngeschakeld\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_IP\n";
print $fh "\tEN\tBridge IP Address\n";
print $fh "\tNL\tBridge IP Adres\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_PORT\n";
print $fh "\tEN\tBridge Port (Default: 38400)\n";
print $fh "\tNL\tBridge Poort (Standaard: 38400)\n";
print $fh "\n";
print $fh "PLUGIN_UPNPVOLUMEBRIDGE_SYNC\n";
print $fh "\tEN\tSync Volume (DAC -> LMS)\n";
print $fh "\tNL\tSynchroniseer Volume (DAC -> LMS)\n";

close($fh);
print "Successfully wrote strings.txt with LEADING tabs.\n";
