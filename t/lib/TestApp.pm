package TestApp;

use strict;
use Catalyst;
use Data::Dumper;

TestApp->config( $ENV{TESTAPP_CONFIG} );

TestApp->setup( @{$ENV{TESTAPP_PLUGINS}} );

1;
