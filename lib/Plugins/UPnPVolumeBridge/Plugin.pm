package Plugins::UPnPVolumeBridge::Plugin;

use strict;
use base qw(Slim::Plugin::Base);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Utils::Timers;
use Slim::Networking::SimpleAsyncHTTP;
use XML::Simple; # LMS includes this

my $prefs = Slim::Utils::Prefs::preferences('plugin.upnpvolumebridge');
my $log   = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.upnpvolumebridge',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_UPNPVOLUMEBRIDGE',
});

my $timer;

sub initPlugin {
	my $class = shift;

	$class->SUPER::initPlugin(@_);

	# Subscribe to mixer (volume) events
	Slim::Control::Request::subscribe(\&volumeCallback, [['mixer']]);

	# Register Settings
	require Plugins::UPnPVolumeBridge::Settings;
	Plugins::UPnPVolumeBridge::Settings->new;

	# Start Polling Timer (every 1 seconds)
	$timer = Slim::Utils::Timers::setTimer($class, Time::HiRes::time() + 1, \&pollVolume);

	$log->info("UPnPVolumeBridge initialized");
}

sub shutdownPlugin {
	my $class = shift;
	if ($timer) {
		Slim::Utils::Timers::killTimers($class, \&pollVolume);
		$timer = undef;
	}
	$class->SUPER::shutdownPlugin(@_);
}

sub volumeCallback {
	my $request = shift;
	
	# Check if this request is a mixer notification
	# We are only interested in volume changes
	my $command = $request->getRequest(0);
	# Some volume requests are 'mixer', 'volume', <val>
	
	my $client = $request->client;
	return unless $client;

	my $id = $client->id;
	return unless $prefs->get("enabled_$id");

	# Prevent loop if the request came from our own polling update
	if ($request->source eq 'PLUGIN_UPNPVOLUMEBRIDGE') {
		return;
	}

	# Get the new volume
	# We want the absolute volume 0-100
	my $vol = $client->volume();
	
	$log->debug("Volume change detected for $id: $vol");

	my $ip = $prefs->get("ip_$id");
	my $port = $prefs->get("port_$id") || '38400';

	if ($ip) {
		sendSetVolume($ip, $port, $vol);
	}
}

sub pollVolume {
	my $class = shift;
	
	$log->debug("Poll timer tick..."); 

	my @clients = Slim::Player::Client::clients();
	$log->debug("Connected clients: " . scalar(@clients));

	for my $client (@clients) {
		my $id = $client->id;
		$log->debug("Checking player $id: enabled=" . ($prefs->get("enabled_$id")//0) . ", sync=" . ($prefs->get("sync_$id")//0));
		
		if ($prefs->get("enabled_$id") && $prefs->get("sync_$id")) {
			my $ip = $prefs->get("ip_$id");
			my $port = $prefs->get("port_$id") || '38400';
			
			if ($ip) {
				$log->debug("Polling volume for $id at $ip"); 
				sendGetVolume($client, $ip, $port);
			}
		}
	}

	# Reschedule
	$timer = Slim::Utils::Timers::setTimer($class, Time::HiRes::time() + 1, \&pollVolume);
}

sub sendSetVolume {
	my ($ip, $port, $vol) = @_;

	my $url = "http://$ip:$port/service/RenderingControl_control";
	my $soap = qq{<?xml version="1.0" encoding="utf-8"?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
   <s:Body>
      <u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
         <InstanceID>0</InstanceID>
         <Channel>Master</Channel>
         <DesiredVolume>$vol</DesiredVolume>
      </u:SetVolume>
   </s:Body>
</s:Envelope>};

	my $http = Slim::Networking::SimpleAsyncHTTP->new(
		\&_setVolumeCallback,
		\&_errorCallback
	);
	
	$http->post($url, 
		'SOAPACTION' => '"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume"',
		'Content-Type' => 'text/xml; charset="utf-8"',
		$soap
	);
}

sub _setVolumeCallback {
	# No specific action needed on success
}

sub sendGetVolume {
	my ($client, $ip, $port) = @_;

	my $url = "http://$ip:$port/service/RenderingControl_control";
	my $soap = qq{<?xml version="1.0" encoding="utf-8"?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
   <s:Body>
      <u:GetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
         <InstanceID>0</InstanceID>
         <Channel>Master</Channel>
      </u:GetVolume>
   </s:Body>
</s:Envelope>};

	my $http = Slim::Networking::SimpleAsyncHTTP->new(
		sub { _getVolumeCallback($client, @_) },
		\&_errorCallback
	);
	
	$http->post($url, 
		'SOAPACTION' => '"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume"',
		'Content-Type' => 'text/xml; charset="utf-8"',
		$soap
	);
}

sub _getVolumeCallback {
	my ($client, $response) = @_;
	
	my $content = $response->content;
	$log->debug("UPnP Response: $content");
	
	if ($content =~ /<CurrentVolume>(\d+)<\/CurrentVolume>/) {
		my $upnpVol = $1;
		my $lmsVol = $client->volume();
		
		# Only update if different to avoid noise
		if (int($upnpVol) != int($lmsVol)) {
			$log->info("Syncing volume from UPnP ($upnpVol) to LMS ($lmsVol)");
			
			# Execute request with specific source to avoid loop
			my $req = Slim::Control::Request::executeRequest($client, ['mixer', 'volume', $upnpVol], { source => 'PLUGIN_UPNPVOLUMEBRIDGE' });
		}
	} else {
		$log->warn("Could not parse volume from UPnP response: " . substr($content, 0, 200));
	}
}

sub _errorCallback {
	my ($http, $error) = @_;
	$log->warn("UPnP Request Error: $error");
}


1;
