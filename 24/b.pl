#!/usr/bin/env perl

use strict;
use warnings;

use Array::Utils qw(intersect);
use Const::Fast;
use List::Util qw(reduce shuffle);
use Math::Utils qw(gcd);
use Scalar::Util::Numeric qw(isint);

const my $LIMIT => 200;

my @lines;
my %raw_deltas = (x => {}, y => {}, z => {});
while (<STDIN>) {
    chomp;
    if (/^\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*@\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*$/) {
        push @lines, {x => $1, y => $2, z => $3, dx => $4, dy => $5, dz => $6};
        push @{$raw_deltas{x}{$4}}, $1;
        push @{$raw_deltas{y}{$5}}, $2;
        push @{$raw_deltas{z}{$6}}, $3;
    }
}

my %deltas;
for my $axis (sort keys %raw_deltas) {
    # Only interested in cases where we have multiple rows with the same delta
    $raw_deltas{$axis} = {map {$_ => $raw_deltas{$axis}{$_}}
        grep {scalar @{$raw_deltas{$axis}{$_}} > 2}
        keys %{$raw_deltas{$axis}}};

    my @reduced = map {@$_}
        # The true delta is the only value that appears everywhere
        reduce {[intersect(@$a, @$b)]}
        sort map {
            # Subtract each coordinate away from it's smaller value,
            # ignoring the first
            my $key = $_;
            my @in = sort {$a <=> $b} @{$raw_deltas{$axis}{$key}};
            my @out;
            for (my $i = 1; $i < scalar @in; $i++) {
                push @out, $in[$i] - $in[$i - 1];
            };

            # Find the GCD and return modified versions of it for cases where
            # the GCD is multiples of the true delta with change
            my $gcd = gcd(@out);
            [
                grep {isint($_)}
                map {($gcd - $key * $_) / $_}
                (-$LIMIT..-1, 1..$LIMIT) # Skip zero
            ]
    } keys %{$raw_deltas{$axis}};

    die "Wrong number for axis '$axis', try increasing \$LIMIT!\n"
        if scalar @reduced != 1;

    $deltas{$axis} = int $reduced[0];
}

print "@{[%deltas]}\n";

# Add deltas to velocities to get a line of possible starts
# Then find the intersection of any two such lines
my ($one, $two) = @{[shuffle(@lines)]}[0,1];

# m = dy / dx, c = y - (dy / /dx) * x
my $my1 = ($one->{dy} + $deltas{y}) / ($one->{dx} + $deltas{x});
my $mz1 = ($one->{dz} + $deltas{z}) / ($one->{dx} + $deltas{x});

my $my2 = ($two->{dy} + $deltas{y}) / ($two->{dx} + $deltas{x});
my $mz2 = ($two->{dz} + $deltas{z}) / ($two->{dx} + $deltas{x});

my $cy1 = $one->{y} - $my1 * $one->{x};
my $cz1 = $one->{z} - $mz1 * $one->{x};

my $cy2 = $two->{y} - $my2 * $two->{x};
my $cz2 = $two->{z} - $mz2 * $two->{x};

my $x1 = ($cy1 - $cy2) / ($my2 - $my1);
my $x2 = ($cz1 - $cz2) / ($mz2 - $mz1); # Quick sanity check

my $y1 = $my1 * $x1 + $cy1;
my $y2 = $my2 * $x1 + $cy2;

my $z1 = $mz1 * $x2 + $cz1;
my $z2 = $mz2 * $x2 + $cz2;

print $x1 + $y1 + $z1 . "\n";
print $x2 + $y2 + $z2 . "\n";
