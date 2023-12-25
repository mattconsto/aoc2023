#!/usr/bin/env perl

use strict;
use warnings;

use Graph::Undirected;
use List::Util qw(product);

my $graph = Graph::Undirected->new;
while (<STDIN>) {
    chomp;
    if (/^\s*(\w+)\s*:\s*([\w+\s*]+)\s*$/) {
        for (split /\s+/, $2) {
            # Found using https://github.com/magjac/d3-graphviz
            next if ($1 eq 'mnh' && $_ eq 'qnv') ||
                    ($1 eq 'ljh' && $_ eq 'tbg') ||
                    ($1 eq 'mfs' && $_ eq 'ffv');
            $graph->add_edge($1, $_);
        }
    }
}

# use Graph::Writer::Dot;
# my $writer = Graph::Writer::Dot->new;
# $writer->write_graph($graph, 'mygraph.dot');

my @totals;
for my $start (qw(xpf pdp)) { # randomly chosen
    my @queue = ($start);
    my %seen;
    my $total = 0;
    while (@queue) {
        my $vertex = shift @queue;
        next if $seen{$vertex};
        $seen{$vertex} = 1;
        $total++;
        push @queue, $graph->neighbours($vertex);
    }
    push @totals, $total;
}
print product(@totals) . "\n";
