package Plugins::Users::Settings;

#
# LMS-Users
#
# Copyright (c) 2026 Craig Drummond <craig.p.drummond@gmail.com>
#
# MIT license.
#

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Misc;
use Slim::Utils::Strings qw(string);
use Slim::Utils::Prefs;

my $log = Slim::Utils::Log->addLogCategory({
    'category'     => 'plugin.users',
    'defaultLevel' => 'ERROR',
});

my $prefs = preferences('plugin.users');
my $serverprefs = preferences('server');

sub name {
    return Slim::Web::HTTP::CSRF->protectName('Users');
}

sub page {
    return Slim::Web::HTTP::CSRF->protectURI('plugins/Users/settings/users.html');
}

sub prefs {
    return ($prefs, 'users');
}

#sub beforeRender {
#    my ($class, $paramRef) = @_;
#}

sub handler {
    my ($class, $client, $paramRef) = @_;
    $paramRef->{credentials}  = Plugins::Users->getAccounts();
    return $class->SUPER::handler($client, $paramRef);
}

1;

__END__
