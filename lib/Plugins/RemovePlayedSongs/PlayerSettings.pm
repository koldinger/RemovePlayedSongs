package Plugins::RemovePlayedSongs::PlayerSettings;

# SqueezeCenter Copyright 2001-2007 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 2.

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Utils::Strings qw (string);
use Slim::Display::NoDisplay;
use Slim::Display::Display;


my $prefs = preferences('plugin.removeplayedsongs');
my $log   = logger('plugin.removeplayedsongs');

sub name {
	return Slim::Web::HTTP::protectName('PLUGIN_REMOVEPLAYEDSONGS');
}

sub needsClient {
	return 1;
}

sub validFor {
	return 1;
}

sub page {
	return Slim::Web::HTTP::protectURI('plugins/RemovePlayedSongs/settings/player.html');
}

sub prefs {
	my $class = shift;
	my $client = shift;
	return ($prefs->client($client), qw(enabled));
}

sub handler {
	my ($class, $client, $params) = @_;
	$log->debug("ResetVolume::PlayerSettings->handler() called. " . $client->name());
	Plugins::ResetVolume::Plugin->extSetDefaults($client, 0);
	# Data::Dump::dump($params);
	if ($params->{'saveSettings'}) {
		$params->{'pref_enabled'} = 0 unless defined $params->{'pref_enabled'};
	}

	return $class->SUPER::handler( $client, $params );
}

1;
