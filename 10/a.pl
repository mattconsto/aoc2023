#!/usr/bin/env perl

use strict;
use warnings;

use List::Util qw(max);

my @map;
while (<STDIN>) {
    chomp;
    push @map, [split //];
}

my $start_y;
my $start_x;
FOUND: {
    for ($start_y = 0; $start_y < scalar @map; $start_y++) {
        for ($start_x = 0; $start_x < scalar @{$map[$start_y]}; $start_x++) {
            last FOUND if $map[$start_y][$start_x] eq 'S';
        }
    }
}

my @seen = map {[(undef) x scalar @$_]} @map;
my @queue = ({
    'x'     => $start_x,
    'y'     => $start_y,
    'depth' => 0,
    'last'  => undef,
});
while (@queue) {
    my $item = shift @queue;
    if (!exists $map[$item->{y}] || !exists $map[$item->{y}][$item->{x}]) {
        die "Out of bounds!";
    }

    if ($seen[$item->{y}][$item->{x}] && $item->{depth} < $seen[$item->{y}][$item->{x}]) {
        die "Got here quicker?!";
    }

    # Already seen
    next if $seen[$item->{y}][$item->{x}];

    my $tile = $map[$item->{y}][$item->{x}];
    if ($tile eq 'S') {
        # North
        push @queue, {
            'x'     => $item->{x},
            'y'     => $item->{y} - 1,
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        } if $item->{y} > 0 && $map[$item->{y} - 1][$item->{x}] =~ /^[\|7F]$/;

        # East
        push @queue, {
            'x'     => $item->{x} + 1,
            'y'     => $item->{y},
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        } if $item->{x} < scalar @{$map[$item->{y}]} && $map[$item->{y}][$item->{x} + 1] =~ /^[\-J7]$/;

        # South
        push @queue, {
            'x'     => $item->{x},
            'y'     => $item->{y} + 1,
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        } if $item->{y} < scalar @map && $map[$item->{y} + 1][$item->{x}] =~ /^[\|LJ]$/;

        # West
        push @queue, {
            'x'     => $item->{x} - 1,
            'y'     => $item->{y},
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        } if $item->{x} > 0 && $map[$item->{y}][$item->{x} - 1] =~ /^[\-LF]$/;
    } elsif ($tile eq '|') {
        my $delta = $item->{y} - $item->{last}->{y};
        die "Not moving!" unless $delta == 1 || $delta == -1;
        push @queue, {
            'x'     => $item->{x},
            'y'     => $item->{y} + $delta,
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        };
    } elsif ($tile eq '-') {
        my $delta = $item->{x} - $item->{last}->{x};
        die "Not moving!" unless $delta == 1 || $delta == -1;
        push @queue, {
            'x'     => $item->{x} + $delta,
            'y'     => $item->{y},
            'depth' => $item->{depth} + 1,
            'last'  => $item,
        };
    } elsif ($tile eq 'L') {
        if ($item->{y} - $item->{last}->{y} == 1) {
            # North -> East
            push @queue, {
                'x'     => $item->{x} + 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } elsif ($item->{x} - $item->{last}->{x} == -1) {
            # East -> North
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} - 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } else {
            die "How did I get here?";
        }
    } elsif ($tile eq 'J') {
        if ($item->{y} - $item->{last}->{y} == 1) {
            # North -> West
            push @queue, {
                'x'     => $item->{x} - 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } elsif ($item->{x} - $item->{last}->{x} == 1) {
            # West -> North
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} - 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } else {
            die "How did I get here?";
        }
    } elsif ($tile eq '7') {
        if ($item->{y} - $item->{last}->{y} == -1) {
            # South -> West
            push @queue, {
                'x'     => $item->{x} - 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } elsif ($item->{x} - $item->{last}->{x} == 1) {
            # West -> South
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} + 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } else {
            die "How did I get here?";
        }
    } elsif ($tile eq 'F') {
        if ($item->{y} - $item->{last}->{y} == -1) {
            # South -> East
            push @queue, {
                'x'     => $item->{x} + 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } elsif ($item->{x} - $item->{last}->{x} == -1) {
            # East -> South
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} + 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
        } else {
            die "How did I get here?";
        }
    } elsif ($tile eq '.') {
        warn "How did I get here?";
    } else {
        die "Unimplemented!";
    }

    $seen[$item->{y}][$item->{x}] = $item->{depth};
}

print max(grep {defined} map {max(grep {defined} @$_)} @seen) . "\n";
