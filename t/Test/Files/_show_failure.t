use strict;
use warnings
  FATAL    => qw( all ),
  NONFATAL => qw( deprecated exec internal malloc newline once portable redefine recursion uninitialized );

use Test::Builder::Tester tests => 2;
use Test::Expander;

const my $MESSAGE => 'message';
const my $SEP     => $^O eq 'MSWin32' ? '\\' : '/';

my $title;

$title = 'error messages in object';
test_out( "not ok 1 - $title" );
test_err(
  "#   Failed test '$title'",
  '#   at ' . path( $TEST_FILE )->relative( cwd() ) =~ s{ [/\\] }{$SEP}grx . ' line ' . line_num( +5 ) . '.',
  "# $MESSAGE"
);
$CLASS->_init->diag( [ $MESSAGE ] )->name( $title )->$METHOD;
test_test( title => $title );

$title = 'error messages supplied as parameter';
test_out( "not ok 1 - $title" );
test_err(
  "#   Failed test '$title'",
  '#   at ' . path( $TEST_FILE )->relative( cwd() ) =~ s{ [/\\] }{$SEP}grx . ' line ' . line_num( +5 ) . '.',
  "# $MESSAGE"
);
$CLASS->_init->name( $title )->$METHOD( $MESSAGE );
test_test( title => $title );
