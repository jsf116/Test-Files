use strict;
use warnings
  FATAL    => qw( all ),
  NONFATAL => qw( deprecated exec internal malloc newline once portable redefine recursion uninitialized );

use Test::Expander -tempdir => {};

use Test::Files::Constants qw( $COMPARE_DIRS_OPTIONS $FMT_SUB_FAILED );

my $diag;
my $sub = sub { path( shift )->basename eq 'GOOD' };
my $mockThis = mock $CLASS => (
  override => [
    _show_failure  => sub { pass( 'Failure reported' ); undef },
    _show_result   => sub {
      my $expected = $FMT_SUB_FAILED =~ s/%s/path( $TEMP_DIR )->child( 'BAD' )/er;
      is( $_[ 2 ], $expected, 'Negative results reported' );
      return;
    },
    _validate_args => sub { shift; ( $diag, path( shift ), shift, $COMPARE_DIRS_OPTIONS ) },
  ]
);

path( $TEMP_DIR )->child( 'SUBDIR' )->mkdir;
path( $TEMP_DIR )->child( 'BAD'  )->touch;
path( $TEMP_DIR )->child( 'GOOD' )->touch;

plan( 2 );                                                  ## no critic (ProhibitMagicNumbers)

subtest 'valid arguments' => sub {
  plan( 2 );                                                ## no critic (ProhibitMagicNumbers)
  $diag = 'ERROR';
  is( $METHOD_REF->( $TEMP_DIR, $sub ), undef, 'executed' );
};

subtest 'invalid arguments' => sub {
  plan( 2 );                                                ## no critic (ProhibitMagicNumbers)
  $diag = undef;
  is( $METHOD_REF->( $TEMP_DIR, $sub ), undef, 'executed' );
};
