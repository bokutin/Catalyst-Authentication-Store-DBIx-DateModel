#!perl

use strict;
use warnings;
use DBI;
use File::Path;
use FindBin;
use Test::More;
use lib "$FindBin::Bin/lib";

BEGIN {
    eval { require Test::WWW::Mechanize::Catalyst }
      or plan skip_all =>
      "Test::WWW::Mechanize::Catalyst is required for this test";

    eval { require DBD::SQLite }
        or plan skip_all =>
        "DBD::SQLite is required for this test";

    eval { require DBIx::DataModel }
        or plan skip_all =>
        "DBIx::DataModel is required for this test";

    eval { require Catalyst::Plugin::Session;
           die unless $Catalyst::Plugin::Session::VERSION >= 0.02 }
        or plan skip_all =>
        "Catalyst::Plugin::Session >= 0.02 is required for this test";

    eval { require Catalyst::Plugin::Session::State::Cookie; }
        or plan skip_all =>
        "Catalyst::Plugin::Session::State::Cookie is required for this test";


    plan tests => 4;

    $ENV{TESTAPP_CONFIG} = {
        name => 'TestApp',	
        authentication => {
            default_realm => "users",
            realms => {
                users => {
                    credential => {
                        'class' => 'Password',
                        'password_field' => 'password',
					},
                    store => {
                        'class' => 'Person',                        
                        'use_userdata_from_session' => 0,
                    },
                },
            },
        },
    };

    $ENV{TESTAPP_PLUGINS} = [
        qw/Authentication
            Session
		    Session::Store::Dummy		   
            Session::State::Cookie				 
           /
    ];
}

use Test::WWW::Mechanize::Catalyst 'TestApp';
my $m = Test::WWW::Mechanize::Catalyst->new;

# log a user in
{
    $m->get_ok( 'http://localhost/user_login?username=joeuser&password=hackme', undef, 'request ok' );
    $m->content_is( 'joeuser logged in', 'user logged in ok' );
}

# verify the user is still logged in
{
    $m->get_ok( 'http://localhost/get_session_user', undef, 'request ok' );
    $m->content_is( 'joeuser', 'user still logged in' );
}


