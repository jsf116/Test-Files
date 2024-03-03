use strict;
use warnings
  FATAL    => qw( all ),
  NONFATAL => qw( deprecated exec internal malloc newline once portable redefine recursion uninitialized );

use Test::Expander -tempdir => {};

use Test::Files::Constants qw( $DIRECTORY_OPTIONS $FMT_SUB_FAILED );

my $diag;
my $sub      = sub { path( shift )->basename eq 'GOOD' };
my $mockThis = mock $CLASS => (
  override => [
    _show_failure  => sub {},
    _show_result   => sub { 1 },
    _validate_args => sub { my $self = shift; $self->diag( $diag ); $sub },
  ]
);

path( $TEMP_DIR )->child( 'SUBDIR' )->mkdir;
path( $TEMP_DIR )->child( 'BAD'  )->touch;
path( $TEMP_DIR )->child( 'GOOD' )->touch;

plan( 2 );

$diag = [];
ok(  $METHOD_REF->( $TEMP_DIR, $sub ), 'valid arguments' );

$diag = [ 'ERROR' ];
ok( !$METHOD_REF->( $TEMP_DIR, $sub ), 'invalid arguments' );
