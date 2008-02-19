# 				Remove Played Songs plugin 
#
#    Copyright (c) 2007 Erland Isaksson (erland_i@hotmail.com)
#                  2008 Modified by Eric Koldinger (slim@koldware.com)
#                       Ported to SqueezeCenter 7
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

package Plugins::RemovePlayedSongs::Plugin;

use strict;

use base qw(Slim::Plugin::Base);

use Slim::Buttons::Home;
use Slim::Utils::Misc;
use Slim::Utils::Prefs;
use Slim::Utils::Strings qw(string);
use File::Spec::Functions qw(:ALL);
use DBI qw(:sql_types);

my %curIndex = {};
my %curSong = {};

my $prefs = preferences('plugin.removeplayedsongs');

sub getDisplayName {
	return 'PLUGIN_REMOVEPLAYEDSONGS';
}

sub initPlugin {
	my $class = shift;
    $class->SUPER::initPlugin(@_);
	Slim::Control::Request::subscribe(\&newSongCallback, [['playlist'], ['newsong']]);
	Slim::Control::Request::subscribe(\&playlistClearedCallback, [['playlist'], ['delete','clear','loadtracks','playtracks','load','play','loadalbum','playalbum']]);
}

sub shutdownPlugin {
	Slim::Control::Request::unsubscribe(\&newSongCallback);
	Slim::Control::Request::unsubscribe(\&playlistClearedCallback);
}

sub newSongCallback {
	my $request = shift;
	my $client = $request->client();	

	if (defined($client) &&
		$prefs->client($client)->get('enabled') &&
		!defined($client->master) &&
		$request->getRequest(0) eq 'playlist')
	{
		my $index = Slim::Player::Source::playingSongIndex($client);
		my $song = Slim::Player::Playlist::song($client);
		if($index > 0 && defined($curIndex{$client})) {
			my $firstSong = Slim::Player::Playlist::song($client, 0);
			my $prevSong = Slim::Player::Playlist::song($client, $curIndex{$client});
			if (defined($prevSong) && defined($curSong{$client}) && $prevSong->url eq $curSong{$client}->url) {
				Slim::Player::Playlist::removeTrack($client, $curIndex{$client});	
				if($curIndex{$client} < $index) {
					$index = $index - 1;
				}
			} elsif (defined($firstSong) && defined($curSong{$client}) && $firstSong->url eq $curSong{$client}->url) {
				Slim::Player::Playlist::removeTrack($client,0);	
				$index = $index - 1;
			}
		}
		$curSong{$client} = $song;
		$curIndex{$client} = $index;
	}	
}

sub playlistClearedCallback
{
	my $request = shift;
	my $client = $request->client();	

	$curIndex{$client} = undef;
	$curSong{$client} = undef;
}

sub setMode {
    my $class = shift;
    my $client = shift;

	$client->lines(\&lines);
}
        
sub lines {
	my $client = shift;
	my ($line1, $line2, $overlay2);
     
	$line1 = $client->string('PLUGIN_REMOVEPLAYEDSONGS');
	my $enabled = $prefs->client($client)->get('enabled');
	$line2 = $client->string($enabled ?  'PLUGIN_REMOVEPLAYEDSONGS_DISABLE' : 'PLUGIN_REMOVEPLAYEDSONGS_ENABLE');
        
	return { 'line1' => $line1, 'line2' => $line2 };
}

my %functions = (
	'up' => sub  {
		my $client = shift;
		$client->bumpUp();
	},
	'down' => sub  {
		my $client = shift;
		$client->bumpDown();
	},
	'right' => sub {
		my $client = shift;
		my $cPrefs = $prefs->client($client);
		my $enabled = $cPrefs->get('enabled');
		$client->showBriefly({ 'line1' => string('PLUGIN_REMOVEPLAYEDSONGS'), 
							   'line2' => string($enabled ? 'PLUGIN_REMOVEPLAYEDSONGS_DISABLING' :
														    'PLUGIN_REMOVEPLAYEDSONGS_ENABLING') });
		$cPrefs->set('enabled', ($enabled ? 0 : 1));
	},
	'left' => sub {
		my $client = shift;
		Slim::Buttons::Common::popModeRight($client);
	},
);

sub getFunctions { return \%functions;}

        
1;
