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

# Enables per-player settings dropdown
sub needsClient {
    return 1;
}

sub handler {
    my ($class, $client, $params, $callback, @args) = @_;
    
    if ($params->{'saveSettings'} && $client) {
        $prefs->client($client)->set('enabled', $params->{'enabled'});
        $prefs->client($client)->set('upnp_control_url', $params->{'upnp_control_url'});
    }
    
    $callback->( $class, {
        'enabled'          => $client ? $prefs->client($client)->get('enabled') : 0,
        'upnp_control_url' => $client ? $prefs->client($client)->get('upnp_control_url') : '',
    } );
}

1;
