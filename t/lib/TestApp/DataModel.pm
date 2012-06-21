package TestApp::DataModel;

use strict;
use warnings;
use DBIx::DataModel;

DBIx::DataModel  # no semicolon (intentional)

#---------------------------------------------------------------------#
#                         SCHEMA DECLARATION                          #
#---------------------------------------------------------------------#
->Schema('TestApp::DataModel::Schema')

#---------------------------------------------------------------------#
#                         TABLE DECLARATIONS                          #
#---------------------------------------------------------------------#
#          Class    Table     PK                                  
#          =====    =====     ==                                  
->Table(qw/User     user      id/)
->Table(qw/Role     role      id/)
->Table(qw/UserRole user_role user roleid/)

#---------------------------------------------------------------------#
#                      ASSOCIATION DECLARATIONS                       #
#---------------------------------------------------------------------#
#     Class    Role      Mult Join                
#     =====    ====      ==== ====                
->Association(
  [qw/User     user      1    id/],
  [qw/UserRole user_role *    user/],
)
->Association(
  [qw/Role     role      1    id/],
  [qw/UserRole user_role *    roleid/],
)
->Association(
  [qw/User     users     *    user_role user/],
  [qw/Role     roles     *    user_role role/],
)
;

1;
