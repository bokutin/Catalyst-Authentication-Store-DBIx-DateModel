#!perl

use strict;
use warnings;
use DBI;
use File::Path;
use FindBin;
use Test::More;
use lib "$FindBin::Bin/lib";

BEGIN {
    eval { require DBD::SQLite }
        or plan skip_all =>
        "DBD::SQLite is required for this test";

    eval { require DBIx::DataModel }
        or plan skip_all =>
        "DBIx::DataModel is required for this test";

    plan tests => 19;

    $ENV{TESTAPP_CONFIG} = {
        name => 'TestApp',
        authentication => {
            default_realm => "users",
            realms => {
                users => {
                    credential => {
                        'class' => "Password",
                        'password_field' => 'password',
                        'password_type' => 'clear'
                    },
                    store => {
                        'class' => 'DBIx::DataModel',
                        'user_model' => 'TestApp::User',
                    },
                },
            },
        },
    };

    $ENV{TESTAPP_PLUGINS} = [
        qw/Authentication/
    ];
}

use Catalyst::Test 'TestApp';

# log a user in
{
    ok( my $res = request('http://localhost/user_login?username=joeuser&password=hackme'), 'request ok' );
    is( $res->content, 'joeuser logged in', 'user logged in ok' );
}

# invalid user
{
    ok( my $res = request('http://localhost/user_login?username=foo&password=bar'), 'request ok' );
    is( $res->content, 'not logged in', 'user not logged in ok' );
}

# disabled user - no disable check
{
    ok( my $res = request('http://localhost/user_login?username=spammer&password=broken'), 'request ok' );
    is( $res->content, 'spammer logged in', 'status check - disabled user logged in ok' );
}

# disabled user - should fail login
{
    ok( my $res = request('http://localhost/notdisabled_login?username=spammer&password=broken'), 'request ok' );
    is( $res->content, 'not logged in', 'status check - disabled user not logged in ok' );
}

# log the user out
{
    ok( my $res = request('http://localhost/user_logout'), 'request ok' );
    is( $res->content, 'logged out', 'user logged out ok' );
}

# searchargs test
{
    ok( my $res = request('http://localhost/searchargs_login?email=nada%40mucho.net&password=much'), 'request ok' );
    is( $res->content, 'nuffin logged in', 'searchargs based login ok' );
}

# result test
{
    ok( my $res = request('http://localhost/result_login?email=j%40cpants.org&password=letmein'), 'request ok' );
    is( $res->content, 'jayk logged in', 'resultset based login ok' );
}

# resultset test
{
    ok( my $res = request('http://localhost/resultset_login?email=j%40cpants.org&password=letmein'), 'request ok' );
    is( $res->content, 'jayk logged in', 'resultset based login ok' );
}

# invalid user
{
    ok( my $res = request('http://localhost/bad_login?username=foo&password=bar'), 'request ok' );
    TODO: {
        local $TODO = "DBIDM hasn't has_columns method.";
        like( $res->content, qr/only has these columns/, 'incorrect parameters to authenticate throws a useful exception' );
    }
}


{
    $ENV{TESTAPP_CONFIG}->{authentication}->{realms}->{users}->{store}->{user_model} = 'Nonexistent::Class';
    my $res = request('http://localhost/user_login?username=joeuser&password=hackme');
    like( $res->content, qr/\$\Qc->model('Nonexistent::Class') did not return a table. Did you set user_model correctly?/, 'test for wrong user_class' );
}
