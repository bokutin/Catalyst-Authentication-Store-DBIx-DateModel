use inc::Module::Install 0.91;

if( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/Catalyst/Authentication/Store/DBIx/DataModel.pm > README' );
}
realclean_files 'README';

## I'd love to use can_use - but I can't seem to test for success. :-/
eval { require Catalyst::Plugin::Authentication::Store::DBIx::DataModel or die 'footy'; };

if (!$@) {   #} can_use("Catalyst::Plugin::Authentication::Store::DBIx::DataModel") ) {
    print STDERR <<EOM;
*******************************************
***  WARNING:  DEPRECATED MODULE FOUND  ***
*******************************************

You have the Catalyst::Plugin::Authentication::Store::DBIx::DataModel installed.
The module you are installing supercedes it and it's presence has been known
to cause conflicts.   We STRONGLY recommend you remove the old module before
proceeding.

You can use CPANPLUS (the cpanp command) to remove the module.

You have 5 seconds to abort this install to remove the old module.
EOM
    sleep 5;
    print STDERR "Ok. Proceeding anyway...\n\nYou are entering a dimension not only of sight and sound, but of mind...\n\n";
}


name 'Catalyst-Authentication-Store-DBIx-DataModel';
all_from 'lib/Catalyst/Authentication/Store/DBIx/DataModel.pm';

perl_version '5.8.1';

requires (
    'Catalyst::Runtime'                 => '5.8',
    'Catalyst::Plugin::Authentication'  => '0.10008',
    'Catalyst::Model::DBIDM'            => 0,
    'DBIx::DataModel'                   => 0,
    'Moose'                             => 0,
    'namespace::autoclean'              => 0,
    'List::MoreUtils'                   => 0,
    'Try::Tiny'                         => 0,
);

test_requires 'Test::More';

resources repository => 'git@github.com:bokutin/Catalyst-Authentication-Store-DBIx-DateModel.git',

auto_install;
auto_provides;
WriteAll;
