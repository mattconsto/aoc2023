#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max min product sum0);

my @lines;
while (<STDIN>) {
    chomp;
    push @lines, [split //, $_];
}

my %gears;
sub check_for_gears {
    my ($start_y, $start_x, $end_x) = @_;

    for (my $y = max(0, $start_y - 1); $y <= min(scalar @lines - 1, $start_y + 1); $y++) {
        for (my $x = max(0, $start_x - 1); $x <= min(scalar @{$lines[$y]} - 1, $end_x + 1); $x++) {
            if ($lines[$y][$x] =~ /\*/) {
                push @{$gears{"$y.$x"}}, (join '', @{$lines[$start_y]}[$start_x..$end_x]);
                return;
            }
        }
    }
}

for (my $y = 0; $y < scalar @lines; $y++) {
    my $start_x;

    my $x = 0;
    for (; $x < scalar @{$lines[$y]}; $x++) {
        if (defined $start_x) {
            if ($lines[$y][$x] !~ /\d/) {
                check_for_gears($y, $start_x, $x - 1);
                $start_x = undef;
            }
        } elsif ($lines[$y][$x] =~ /\d/) {
            $start_x = $x;
        }
    }

    check_for_gears($y, $start_x, $x - 1) if defined $start_x;
}

print sum0(map {product(@{$gears{$_}})} grep {scalar @{$gears{$_}} == 2} (keys %gears)) . "\n";
