# Copyright (C) 2006-2009, Parrot Foundation.
# $Id$

package Parrot::Test::WMLScript;

require Parrot::Test;

=head1 Testing routines specific to 'WMLScript'.

=head2 Description

Call WMLScript compiler, translator and parrot.

=head2 Methods

=head3 new

Yet another constructor.

=cut

use strict;
use warnings;

use File::Spec;

sub new {
    return bless {};
}

my %language_test_map = (
    output_is   => 'is_eq',
    output_like => 'like',
    output_isnt => 'isnt_eq',
);

foreach my $func ( keys %language_test_map ) {
    no strict 'refs';

    *{"Parrot::Test::WMLScript::$func"} = sub {
        my $self = shift;
        my ( $code, $output, $desc, %options ) = @_;

        my $count = $self->{builder}->current_test + 1;

        my $cflags   = $options{cflags}   || q{};
        my $function = $options{function} || 'main';
        my $params   = $options{params}   || q{};

        my $parrot = File::Spec->catfile( $self->{relpath}, $self->{parrot} );
        # flatten filenames (don't use directories)
        my $lang_fn = File::Spec->rel2abs( Parrot::Test::per_test( '.wmls',  $count ) );
        my $bin_fn  = File::Spec->rel2abs( Parrot::Test::per_test( '.wmlsc', $count ) );
        my $out_fn  = File::Spec->rel2abs( Parrot::Test::per_test( '.out',   $count ) );

        # This does not create byte code, but WMLScript code
        Parrot::Test::write_code_to_file( $code, $lang_fn );

        Parrot::Test::run_command(
            "wmlsc $cflags ${lang_fn}",
            STDOUT => $out_fn,
            STDERR => $out_fn,
        );

        my @test_prog = (

            # "wmlsc $cflags $lang_fn",
            # "$parrot wmls2pir.pir $bin_fn",
            "$parrot wmlsi.pir $bin_fn $function $params",
        );

        # STDERR is written into same output file
        my $exit_code = Parrot::Test::run_command(
            \@test_prog,
            STDOUT => $out_fn,
            STDERR => $out_fn,
        );

        my $builder_func = $language_test_map{$func};

        # That's the reason for:   no strict 'refs';
        my $pass =
            $self->{builder}->$builder_func( Parrot::Test::slurp_file($out_fn), $output, $desc );
        unless ($pass) {
            my $diag = q{};
            my $test_prog = join ' && ', @test_prog;
            $diag .= "'$test_prog' failed with exit code $exit_code."
                if $exit_code;
            $self->{builder}->diag($diag) if $diag;
        }

        # The generated files are left in the t/* directories.
        # Let 'make clean' and 'svn:ignore' take care of them.

        return $pass;
        }
}

=head2 History

Mostly taken from F<languages/bc/lib/Parrot/Test/Bc.pm>.

=head2 See Also

F<languages/tcl/lib/Parrot/Test/Tcl.pm>, F<languages/lua/t/Parrot/Test/lua.pm>

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

