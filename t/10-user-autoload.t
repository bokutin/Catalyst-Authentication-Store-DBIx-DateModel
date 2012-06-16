use strict;
use warnings;
use Test::More;
use Catalyst::Authentication::Store::DBIx::Class::User;

my $message = 'I exist';

{
  package My::Test;

  sub exists { $message }
}

my $o = bless({
  _user => bless({}, 'My::Test'),
}, 'Catalyst::Authentication::Store::DBIx::Class::User');

is($o->exists, $message, 'AUTOLOAD proxies ok');

ok(my $meth = $o->can('exists'), 'can returns true');

is($o->$meth, $message, 'can returns right coderef');

is($o->can('non_existent_method'), undef, 'can on non existent method returns undef');

done_testing;
