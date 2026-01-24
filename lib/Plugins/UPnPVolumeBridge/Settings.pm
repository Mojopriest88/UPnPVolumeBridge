package Plugins::UPnPVolumeBridge::Settings;

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::Client;

my $prefs = Slim::Utils::Prefs::preferences('plugin.upnpvolumebridge');
my $log   = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.upnpvolumebridge',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_UPNPVOLUMEBRIDGE',
});

sub name {
	return 'PLUGIN_UPNPVOLUMEBRIDGE';
}

sub page {
	return 'plugins/UPnPVolumeBridge/settings.html';
}

sub prefs {
	return $prefs;
}

sub handler {
	my ($class, $client, $params, $callback, @args) = @_;

	if ($params->{'saveSettings'}) {
		for my $c (Slim::Player::Client::clients()) {
			my $id = $c->id;
			$prefs->set("enabled_$id", $params->{"enabled_$id"} ? 1 : 0);
			$prefs->set("ip_$id", $params->{"ip_$id"} || '');
			$prefs->set("port_$id", $params->{"port_$id"} || '38400');
			$prefs->set("sync_$id", $params->{"sync_$id"} ? 1 : 0);
		}
		$log->info("Settings saved");
	}

	my @players;
	for my $c (Slim::Player::Client::clients()) {
		my $id = $c->id;
		push @players, {
			id      => $id,
			name    => $c->name,
			enabled => $prefs->get("enabled_$id"),
			ip      => $prefs->get("ip_$id"),
			port    => $prefs->get("port_$id") || '38400',
			sync    => $prefs->get("sync_$id"),
		};
	}

	$params->{'players'} = \@players;

	return $class->SUPER::handler($client, $params, $callback, @args);
}

1;
