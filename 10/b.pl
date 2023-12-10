#!/usr/bin/env perl

use strict;
use warnings;

# Read the input
my @map;
while (<STDIN>) {
    chomp;
    push @map, [split //];
}

# Parse the input
my $start_y;
my $start_x;
FOUND: {
    for ($start_y = 0; $start_y < scalar @map; $start_y++) {
        for ($start_x = 0; $start_x < scalar @{$map[$start_y]}; $start_x++) {
            last FOUND if $map[$start_y][$start_x] eq 'S';
        }
    }
}

# Find the loop
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
        my %dirs;
        # North
        if ($item->{y} > 0 && $map[$item->{y} - 1][$item->{x}] =~ /^[\|7F]$/) {
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} - 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
            $dirs{north} = 1;
        }

        # East
        if($item->{x} < scalar @{$map[$item->{y}]} && $map[$item->{y}][$item->{x} + 1] =~ /^[\-J7]$/) {
            push @queue, {
                'x'     => $item->{x} + 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
            $dirs{east} = 1;
        }

        # South
        if ($item->{y} < scalar @map && $map[$item->{y} + 1][$item->{x}] =~ /^[\|LJ]$/) {
            push @queue, {
                'x'     => $item->{x},
                'y'     => $item->{y} + 1,
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
            $dirs{south} = 1;
        }

        # West
        if ($item->{x} > 0 && $map[$item->{y}][$item->{x} - 1] =~ /^[\-LF]$/) {
            push @queue, {
                'x'     => $item->{x} - 1,
                'y'     => $item->{y},
                'depth' => $item->{depth} + 1,
                'last'  => $item,
            };
            $dirs{west} = 1;
        }

        # Patch up the starting map
        $map[$item->{y}][$item->{x}] =
            $dirs{north} && $dirs{south} ? '|' :
            $dirs{east} && $dirs{west} ? '-' :
            $dirs{north} && $dirs{east} ? 'L' :
            $dirs{north} && $dirs{west} ? 'J' :
            $dirs{south} && $dirs{west} ? '7' :
            $dirs{south} && $dirs{east} ? 'F' : (die "Unimplemented!");
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

# Embiggen the loop
my @new_map;
for (my $y = 0; $y < scalar @map; $y++) {
    my @row;
    for (my $x = 0; $x < scalar @{$map[$y]}; $x++) {
        if (defined $seen[$y][$x]) {
            if ($x < scalar @{$map[$y]} && defined $seen[$y][$x + 1]) {
                my $this = $map[$y][$x];
                my $next = $map[$y][$x + 1];
                if ($this =~ /^[\-LF]$/ && $next =~ /^[\-J7]$/) {
                    push @row, ('#', '#');
                } else {
                    push @row, ('#', ' ');
                }
            } else {
                push @row, ('#', ' ');
            }
        } else {
            push @row, ('?', ' ');
        }
    }
    push @new_map, [@row];
    @row = ();
    for (my $x = 0; $x < scalar @{$map[$y]}; $x++) {
        if (defined $seen[$y][$x]) {
            if ($y < scalar @map && defined $seen[$y + 1][$x]) {
                my $this = $map[$y][$x];
                my $next = $map[$y + 1][$x];
                if ($this =~ /^[\|7F]$/ && $next =~ /^[\|LJ]$/) {
                    push @row, ('#', ' ');
                } else {
                    push @row, (' ', ' ');
                }
            } else {
                push @row, (' ', ' ');
            }
        } else {
            push @row, (' ', ' ');
        }
    }
    push @new_map, [@row];
}

# Remove any ? that is connected to 0,0
my @new_queue = ([0, 0]);
my @new_seen = map {[(undef) x scalar @$_]} @new_map;
while (@new_queue) {
    my $coords = shift @new_queue;
    my ($y, $x) = @$coords;

    next if $y < 0 || $y > scalar @new_map || $x < 0 || $x > scalar @{$new_map[$y]};
    next if $new_seen[$y][$x];

    push @new_queue, [$y - 1, $x    ] if exists $new_map[$y - 1] && exists $new_map[$y - 1][$x    ] && $new_map[$y - 1][$x    ] ne '#';
    push @new_queue, [$y + 1, $x    ] if exists $new_map[$y + 1] && exists $new_map[$y + 1][$x    ] && $new_map[$y + 1][$x    ] ne '#';
    push @new_queue, [$y    , $x - 1] if exists $new_map[$y    ] && exists $new_map[$y    ][$x - 1] && $new_map[$y    ][$x - 1] ne '#';
    push @new_queue, [$y    , $x + 1] if exists $new_map[$y    ] && exists $new_map[$y    ][$x + 1] && $new_map[$y    ][$x + 1] ne '#';

    $new_map[$y][$x] = ' ';
    $new_seen[$y][$x] = 1;
}

my $results = grep {/\?/} map {@$_} @new_map;
print "$results\n";
