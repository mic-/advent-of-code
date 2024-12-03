# Advent of Code 2024 - Day 3: Mull It Over, part 1
# Mic, 2024

use strict;
use warnings;
use List::Util qw(sum);

my $number_args = $#ARGV + 1;
if ($number_args != 1) {
    print "Error: no input file specified.\n";
    exit;
}

my $filename = $ARGV[0];
open my $input, $filename or die "Could not open $filename: $!";
chomp(my @lines = <$input>);
close $input;

my @valid_muls;
foreach my $line (@lines) {
    push @valid_muls, $line =~ /mul\(([0-9]+),([0-9]+)\)/g;
}

printf "Sum of multiplications: %d", sum(map { $valid_muls[$_*2] * $valid_muls[$_*2 + 1] } (0 .. @valid_muls/2-1));