#!/usr/bin/env perl

use strict;
use warnings;

use Graph::Undirected;
use Graph::Writer::Dot;
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

my $writer = Graph::Writer::Dot->new;
$writer->write_graph($graph, '25.dot');

# Then use the following HTML to visualise the graph, and find the wires to disconnect:
# <!DOCTYPE html>
# <meta charset="utf-8">
# <body>
# <script src="https://d3js.org/d3.v5.min.js"></script>
# <script src="https://unpkg.com/@hpcc-js/wasm@0.3.11/dist/index.min.js"></script>
# <script src="https://unpkg.com/d3-graphviz@3.0.5/build/d3-graphviz.js"></script>
# <div id="graph"></div>
# <script>d3.select("#graph").graphviz().renderDot(`
# graph g {
# ...
# }`);</script>

my @totals;
for my $start (qw(xpf pdp)) { # previously found values
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
