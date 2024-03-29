package TestApp::Controller::Root;

use Moose;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub user_login : Global {
    my ( $self, $c ) = @_;

    ## this allows anyone to login regardless of status.
    eval {
        $c->authenticate({ username => $c->request->params->{'username'},
                           password => $c->request->params->{'password'}
                         });
        1;
    } or do {
        return $c->res->body($@);
    };

    if ( $c->user_exists ) {
        if ( $c->req->params->{detach} ) {
            $c->detach( $c->req->params->{detach} );
        }
        $c->res->body( $c->user->get('username') . ' logged in' );
    }
    else {
        $c->res->body( 'not logged in' );
    }
}


sub notdisabled_login : Global {
    my ( $self, $c ) = @_;

    $c->authenticate({ username => $c->request->params->{'username'},
                       password => $c->request->params->{'password'},
                       status => [ 'active', 'registered' ]
                     });

    if ( $c->user_exists ) {
        if ( $c->req->params->{detach} ) {
            $c->detach( $c->req->params->{detach} );
        }
        $c->res->body( $c->user->get('username') .  ' logged in' );
    }
    else {
        $c->res->body( 'not logged in' );
    }
}

sub searchargs_login : Global {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{'username'} || '';
    my $email = $c->request->params->{'email'} || '';

    $c->authenticate({
                        password => $c->request->params->{'password'},
                        #dbix_class => {
                        #    searchargs => [ { "-or" => [ username => $username,
                        #                                email => $email ]},
                        #                    { prefetch => qw/ map_user_role /}
                        #                  ]
                        #},
                        dbix_datamodel => {
                            selectargs => [
                                -where     => { "-or" => [ username => $username, email => $email ] },
                                -result_as => "firstrow",
                            ]
                        }
                     });

    if ( $c->user_exists ) {
        if ( $c->req->params->{detach} ) {
            $c->detach( $c->req->params->{detach} );
        }
        $c->res->body( $c->user->get('username') .  ' logged in' );
    }
    else {
        $c->res->body( 'not logged in' );
    }
}

sub result_login : Global {
    my ($self, $ctx) = @_;

    my $user = $ctx->model('TestApp::User')->select(
        -where => { email => $ctx->request->params->{email} },
        -result_as => "firstrow",
    );

    if ($user->{password} ne $ctx->request->params->{password}) {
        $ctx->response->status(403);
        $ctx->response->body('password mismatch');
        $ctx->detach;
    }

    $ctx->authenticate({
        dbix_datamodel => { row => $user },
        password       => $ctx->request->params->{password},
    });

    if ($ctx->user_exists) {
        $ctx->res->body( $ctx->user->get('username') .  ' logged in' );
    }
    else {
        $ctx->res->body('not logged in');
    }
}

sub resultset_login : Global {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{'username'} || '';
    my $email = $c->request->params->{'email'} || '';


    #my $rs = $c->model('TestApp::User')->search({ "-or" => [ username => $username,
    #                                                          email => $email ]});
    my $stmt = $c->model('TestApp::User')->select(
        -where     => { "-or" => [ username => $username, email => $email ] },
        -result_as => "statement",
    );

    $c->authenticate({
                        password => $c->request->params->{'password'},
                        dbix_datamodel => { statement => $stmt },
                     });

    if ( $c->user_exists ) {
        if ( $c->req->params->{detach} ) {
            $c->detach( $c->req->params->{detach} );
        }
        $c->res->body( $c->user->get('username') .  ' logged in' );
    }
    else {
        $c->res->body( 'not logged in' );
    }
}

sub bad_login : Global {
    my ( $self, $c ) = @_;

    ## this allows anyone to login regardless of status.
    eval {
        $c->authenticate({ william => $c->request->params->{'username'},
                           the_bum => $c->request->params->{'password'}
                         });
        1;
    } or do {
        return $c->res->body($@);
    };

    if ( $c->user_exists ) {
        if ( $c->req->params->{detach} ) {
            $c->detach( $c->req->params->{detach} );
        }
        $c->res->body( $c->user->get('username') . ' logged in' );
    }
    else {
        $c->res->body( 'not logged in' );
    }
}

## need to add a resultset login test and a search args login test

sub user_logout : Global {
    my ( $self, $c ) = @_;

    $c->logout;

    if ( ! $c->user ) {
        $c->res->body( 'logged out' );
    }
    else {
        $c->res->body( 'not logged ok' );
    }
}

sub get_session_user : Global {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ) {
        $c->res->body($c->user->get('username')); # . " " . Dumper($c->user->get_columns()) );
    }
}

sub is_admin : Global {
    my ( $self, $c ) = @_;

    eval {
        if ( $c->assert_user_roles( qw/admin/ ) ) {
            $c->res->body( 'ok' );
        }
    };
    if ($@) {
        $c->res->body( 'failed' );
    }
}

sub is_admin_user : Global {
    my ( $self, $c ) = @_;

    eval {
        if ( $c->assert_user_roles( qw/admin user/ ) ) {
            $c->res->body( 'ok' );
        }
    };
    if ($@) {
        $c->res->body( 'failed' );
    }
}

sub set_usersession : Global {
    my ( $self, $c, $value ) = @_;
    $c->user_session->{foo} = $value;
    $c->res->body( 'ok' );
}

sub get_usersession : Global {
    my ( $self, $c ) = @_;
    $c->res->body( $c->user_session->{foo} || '' );
}

__PACKAGE__->meta->make_immutable;

1;
