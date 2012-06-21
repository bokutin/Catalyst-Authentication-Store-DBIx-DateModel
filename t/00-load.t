#!perl 

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Authentication::Store::DBIx::DataModel' );
}

diag( "Testing Catalyst::Authentication::Store::DBIx::DataModel $Catalyst::Authentication::Store::DBIx::DataModel::VERSION, Perl $], $^X" );
