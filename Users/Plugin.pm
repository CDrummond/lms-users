package Plugins::Users::Plugin;;

#
# LMS-Users
#
# Copyright (c) 2026 Craig Drummond <craig.p.drummond@gmail.com>
#
# MIT license.
#

use strict;

use base qw(Slim::Plugin::Base);

use Slim::Utils::Log;
use Slim::Utils::Misc;
use Slim::Utils::Prefs;
use Slim::Utils::Strings qw(string);
use Time::HiRes qw/gettimeofday/;

my $log = Slim::Utils::Log->addLogCategory({
    'category' => 'plugin.users',
    'defaultLevel' => 'ERROR',
    'description' => 'PLUGIN_USERS'
});

my $prefs = preferences('plugin.users');

sub getDisplayName {
    return 'PLUGIN_USERS';
}

sub initPlugin {
    my $class = shift;
    $class->initCLI();
    $class->SUPER::initPlugin(@_);
}

sub shutdownPlugin {
}

sub initCLI {
    Slim::Control::Request::addDispatch(['users', '_cmd'], [0, 0, 1, \&_cliCommand]);
}

sub getAccounts {
}

sub _cliCommand {
    my $request = shift;

    # check this is the correct query.
    if ($request->isNotCommand([['users']])) {
        $request->setStatusBadDispatch();
        return;
    }

    my $cmd = $request->getParam('_cmd');

    if ($request->paramUndefinedOrNotOneOf($cmd, ['list', 'add', 'update', 'delete', 'details']) ) {
        $request->setStatusBadParams();
        return;
    }

    if ($cmd eq 'list') {
        my $ids = $prefs->get('ids');
        if ($ids) {
            my @list = split(/,/, $ids);
            my $cnt = 0;
            foreach my $id (@list) {
                $request->addResultLoop("users_loop", $cnt, "id", $id);
                $request->addResultLoop("users_loop", $cnt, "name", $prefs->get("name_${id}"));
                $request->addResultLoop("users_loop", $cnt, "avatar", $prefs->get("avatar_${id}"));
                $cnt++;
            }
        }
        $request->setStatusDone();
        return;
    }

    if ($cmd eq 'add') {
        my $name = $request->getParam('name');
        my $avatar = $request->getParam('avatar');
        if ($name) {
            my $id = 1;
            my $ids = $prefs->get('ids');
            my @list = ();
            if ($ids) {
                @list = split(/,/, $ids);
                my $cnt = 0;
                foreach my $i (@list) {
                    my $n = $prefs->get("name_${i}");
                    if ($n eq $name) {
                        $request->addResult("id", $i);
                        $request->addResult("new", 0);
                        $request->setStatusDone();
                        return;
                    }
                    my $val = int($id);
                    if ($val>=$id) {
                        $id = $val+1;
                    }
                }
            }
            push(@list, $id);
            $prefs->set('ids', join(',', @list));
            $prefs->set("name_${id}", $name);
            if ($avatar) {
                $prefs->set("avatar_${id}", $avatar);
            }
            $request->addResult("id", $id);
            $request->addResult("new", 1);
            $request->setStatusDone();
            return;
        }
        $request->setStatusBadParams();
    }

    if ($cmd eq 'update') {
        my $name = $request->getParam('name');
        my $avatar = $request->getParam('avatar');
        my $id = $request->getParam('id');
        my $updated = 0;
        if ($id) {
            if ($name) {
                my $n = $prefs->get("name_${id}");
                if ($n ne $name) {
                    $updated=1;
                    $prefs->set("name_${id}", $name);
                }
            }
            if ($avatar) {
                my $a = $prefs->get("avatar_${id}");
                if ($a ne $avatar) {
                    $updated=1;
                    $prefs->set("avatar_${id}", $avatar);
                }
            }
            $request->addResult("updated", $updated);
            $request->setStatusDone();
            return;
        }
        $request->setStatusBadParams();
    }

    if ($cmd eq 'delete') {
        my $id = $request->getParam('id');
        if ($id) {
            my $ids = $prefs->get('ids');
            if ($ids) {
                my @list = split(/,/, $ids);
                my @updated = ();
                my $found = 0;
                foreach my $i (@list) {
                    if ($i eq $id) {
                        $found = 1;
                    } else {
                        push(@updated, $i);
                    }
                }
                if ($found) {
                    $prefs->remove("name_${id}");
                    $prefs->remove("avatar_${id}");
                    $prefs->set('ids', join(',', @updated));
                    $request->setStatusDone();
                    return;
                }
            }
        }
        $request->setStatusBadParams();
    }

    if ($cmd eq 'details') {
        my $id = $request->getParam('id');
        if ($id) {
            my $ids = $prefs->get('ids');
            if ($ids) {
                my @list = split(/,/, $ids);
                my $found = 0;
                foreach my $i (@list) {
                    if ($i eq $id) {
                        my $avatar = $prefs->get("avatar_${id}");
                        $request->addResult("id", $id);
                        $request->addResult("name", $prefs->get("name_${id}"));
                        if ($avatar) {
                            $request->addResult("avatar", $avatar);
                        }
                        $request->setStatusDone();
                        return;
                    }
                }
            }
        }
        $request->setStatusBadParams();
    }

    $request->setStatusBadParams();
}

1;
