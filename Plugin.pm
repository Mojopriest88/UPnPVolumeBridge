package Plugins::UPnPVolumeBridge::Plugin;

use strict;
use base qw(Slim::Plugin::Base);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Networking::SimpleAsyncHTTP;
use Scalar::Util qw(blessed);

# Create a log category for debugging
my $log = Slim::Utils::Log->addLogCategory({
    'category'     => 'plugin.upnpvolumebridge',
    'defaultLevel' => 'INFO',
    'description'  => 'UPnP Volume Bridge',
});

# Access preferences scoped to this plugin
my $prefs = Slim::Utils::Prefs::preferences('plugin.upnpvolumebridge');

sub initPlugin {
    my $class = shift;
    
    $log->info("Initializing UPnP Volume Bridge Plugin");
    $class->SUPER::initPlugin(@_);
    
    # Subscribe to volume and mute notifications
    Slim::Control::Request::subscribe( \&onNotification, [['volume', 'mute']] );
}

sub shutdownPlugin {
    my $class = shift;
    Slim::Control::Request::unsubscribe( \&onNotification );
}

sub onNotification {
    my $request = shift;
    my $client  = $request->client();

    # Ensure we have a valid client object
    return unless (defined $client && blessed($client));

    # 1. Check if the bridge is enabled for THIS specific player
    my $enabled = $prefs->client($client)->get('enabled');
    return unless $enabled;

    # 2. Get the UPnP URL for THIS specific player
    my $upnp_url = $prefs->client($client)->get('upnp_control_url');
    return unless $upnp_url;

    my $type = $request->getRequest(0);

    # Handle Volume Changes
    if ($type eq 'volume') {
        my $new_volume = $request->getParam('_new');
        
        # Fallback if _new is not in params
        unless (defined $new_volume) {
            $new_volume = $client->volume();
        }
        
        # Ensure volume is an integer (UPnP requirement)
        $new_volume = int($new_volume);
        
        $log->info("Player [" . $client->name() . "] volume changed: $new_volume. Forwarding to UPnP...");
        sendUpnpVolume($upnp_url, $new_volume);
    }
    # Handle Mute Changes
    elsif ($type eq 'mute') {
        my $new_mute = $request->getParam('_new');
        
        # Fallback if _new is not in params
        unless (defined $new_mute) {
            $new_mute = $client->isMuted() ? 1 : 0;
        }
        
        $log->info("Player [" . $client->name() . "] mute toggled: $new_mute. Forwarding to UPnP...");
        sendUpnpMute($upnp_url, $new_mute);
    }
}

sub sendUpnpVolume {
    my ($url, $volume) = @_;

    # SOAP Body for UPnP SetVolume
    my $soap_body = qq{<?xml version="1.0" encoding="utf-8"?>
    <s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
       <s:Body>
          <u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
             <InstanceID>0</InstanceID>
             <Channel>Master</Channel>
             <DesiredVolume>$volume</DesiredVolume>
          </u:SetVolume>
       </s:Body>
    </s:Envelope>};

    sendSoapRequest($url, $soap_body, "SetVolume");
}

sub sendUpnpMute {
    my ($url, $mute_state) = @_;
    $mute_state = $mute_state ? 1 : 0;

    # SOAP Body for UPnP SetMute
    my $soap_body = qq{<?xml version="1.0" encoding="utf-8"?>
    <s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
       <s:Body>
          <u:SetMute xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
             <InstanceID>0</InstanceID>
             <Channel>Master</Channel>
             <DesiredMute>$mute_state</DesiredMute>
          </u:SetMute>
       </s:Body>
    </s:Envelope>};

    sendSoapRequest($url, $soap_body, "SetMute");
}

sub sendSoapRequest {
    my ($url, $body, $action) = @_;

    my %headers = (
        'Content-Type' => 'text/xml; charset="utf-8"',
        'SOAPAction'   => qq{"urn:schemas-upnp-org:service:RenderingControl:1#$action"},
    );

    # Use SimpleAsyncHTTP to prevent blocking the LMS main thread
    Slim::Networking::SimpleAsyncHTTP->new(
        \&_httpResponse,
        \&_httpError,
        { timeout => 5 },
    )->post($url, $body, \%headers);
}

sub _httpResponse {
    my $http = shift;
    my $result = shift;
    $log->info("UPnP request succeeded");
}

sub _httpError {
    my $error = shift;
    $log->error("UPnP Request Error: " . (defined $error ? $error : "Unknown error"));
}

1;
