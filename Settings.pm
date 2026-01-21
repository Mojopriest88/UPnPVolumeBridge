package Plugins::UPnPVolumeBridge::Settings;

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Prefs;

my $prefs = Slim::Utils::Prefs::preferences('plugin.upnpvolumebridge');

$prefs->init({
    enabled          => 0,
    upnp_control_url => '', 
});

sub name {
    return 'UPnP Volume Bridge';
}

sub page {
    return 'plugins/UPnPVolumeBridge/settings.html';
}

sub prefs {
    return $prefs;
}

sub needsClient {
    return 1;
}

1;
