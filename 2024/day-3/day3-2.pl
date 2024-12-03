# Advent of Code 2024 - Day 3: Mull It Over, part 2
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
    push @valid_muls, $line =~ /(don't)|(do)|mul\(([0-9]+),([0-9]+)\)/g;
}
@valid_muls = grep defined,@valid_muls;

my $i = 0;
my $enabled = 1;
my $sum = 0;
while ($i < @valid_muls-1) {
   if ($valid_muls[$i] eq "do") {
       $enabled = 1;
   } elsif ($valid_muls[$i] eq "don't") {
       $enabled = 0;
   } else {
       if ($enabled) {
           $sum += $valid_muls[$i] * $valid_muls[$i+1];
       }
       $i++;
   }
   $i++;
}
printf "Sum of multiplications: %d", $sum;