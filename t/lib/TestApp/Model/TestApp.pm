package TestApp::Model::TestApp;

use Moose;
extends qw(Catalyst::Model::DBIDM);

use TestApp::DataModel;

my @deployment_statements = split /;/, q{
    CREATE TABLE user (
        id       INTEGER PRIMARY KEY,
        username TEXT,
        email    TEXT,
        password TEXT,
        status   TEXT,
        role_text TEXT,
        session_data TEXT
    );
    CREATE TABLE role (
        id   INTEGER PRIMARY KEY,
        role TEXT
    );
    CREATE TABLE user_role (
        id   INTEGER PRIMARY KEY,
        user INTEGER,
        roleid INTEGER
    );

    INSERT INTO user VALUES (1, 'joeuser', 'joeuser@nowhere.com', 'hackme', 'active', 'admin', NULL);
    INSERT INTO user VALUES (2, 'spammer', 'bob@spamhaus.com', 'broken', 'disabled', NULL, NULL);
    INSERT INTO user VALUES (3, 'jayk', 'j@cpants.org', 'letmein', 'active', NULL, NULL);
    INSERT INTO user VALUES (4, 'nuffin', 'nada@mucho.net', 'much', 'registered', 'user admin', NULL);
    INSERT INTO role VALUES (1, 'admin');
    INSERT INTO role VALUES (2, 'user');
    INSERT INTO user_role VALUES (1, 3, 1);
    INSERT INTO user_role VALUES (2, 3, 2);
    INSERT INTO user_role VALUES (3, 4, 2)
};

__PACKAGE__->config(
    schema_class => 'TestApp::DataModel::Schema',
    use_singleton => 0,
);

my $schema;
override get_schema_instance => sub {
    my ($self, $c, $schema_class) = @_;

    $schema ||= do {
        use DBI;
        my $dbh = DBI->connect(
            "dbi:SQLite:dbname=:memory:",
            '',
            '',
            { AutoCommit => 1, RaiseError => 1 },
        );

        for (@deployment_statements) {
            $dbh->do($_) or die $dbh->errstr;
        }

        $schema_class->new(
            dbh => $dbh,
        );
    };
};

1;
