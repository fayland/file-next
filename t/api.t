#!perl -T

use strict;
use warnings;
use Test::More tests => 18;

BEGIN {
    use_ok( 'File::Next' );
}

CHECK_FILE_FILTER: {
    my $file_filter = sub {
        return if $File::Next::dir =~ /\.svn/;
        ok( defined $_, '$_ defined' );
        is( $File::Next::dir, File::Next::_reslash( 't/swamp' ), '$File::Next::dir correct in $file_filter' );
        is( $File::Next::name, File::Next::_reslash( "t/swamp/$_" ) );
    };

    my $iter = File::Next::files( {file_filter => $file_filter}, 't/swamp' );
    isa_ok( $iter, 'CODE' );

    # Return filename in scalar mode
    my $file = $iter->();
    my $swamp = File::Next::_reslash( 't/swamp' );
    like( $file, qr{^\Q$swamp\E.+}, 'swamp filename returned' );

    # Return $dir and $file in list mode
    my $dir;
    ($dir,$file) = $iter->();
    is( $dir, $swamp, 'Correct $dir' );
    unlike( $file, qr{/\\:}, '$file should not have any slashes, backslashes or other pathy things' );
}

CHECK_DESCEND_FILTER: {
    my $swamp = File::Next::_reslash( 't/swamp' );
    my $descend_filter = sub {
        return if $File::Next::dir =~ /\.svn/;
        ok( defined $_, '$_ defined' );
        like( $File::Next::dir, qr{^\Q$swamp}, '$File::Next::dir in $descend_filter' );
    };

    my $iter = File::Next::files( {descend_filter => $descend_filter}, $swamp );
    isa_ok( $iter, 'CODE' );

    while ( $iter->() ) {
        # Do nothing, just calling the descend
    }
}
