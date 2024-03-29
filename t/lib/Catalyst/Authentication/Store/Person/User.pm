package Catalyst::Authentication::Store::Person::User;

use strict;
use warnings;
use base qw/Catalyst::Authentication::Store::DBIx::DataModel::User/;
use base qw/Class::Accessor::Fast/;
use Data::Dump;

sub load {
    my ($self, $authinfo, $c) = @_;	
	if ( exists( $authinfo->{'id'} ) ) {		
        $self->_user( $c->model('TestApp::User')->fetch($authinfo->{'id'}) );		
    } elsif ( exists( $authinfo->{'username'} ) ) {
		my $u = $c->model('TestApp::User')->select( -where => { username => $authinfo->{'username'} }, -result_as => "firstrow" );
	    $self->_user( $u );
	}
    if ($self->get_object) {
        return $self;
    } else {
        return undef;
    }
}

1;
__END__
