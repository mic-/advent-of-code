# Advent of Code 2023 - Day 12: Hot Springs, part 1
# Mic, 2023

use strict;
use warnings;
use List::Util qw(sum);

# E.g. "F00FF",/F.*F/ => 3 (i.e. F00F, F00FF, FF)
sub exhaustive_match_count {
    my $count = 0;
    while ($_[0] =~ /$_[1](?{$count += 1;})(?!)/) {}
    return $count;
}

# E.g. (1, 1, 3) => /^[^#]*[#\?][^#]+[#\?][^#]+[#\?]{3}[^#]*$/
sub generate_regex_for_groups {
    my $regex_str = join("[^#]+", map { $_ > 1 ? "[#\\?]{$_}" : "[#\\?]" } @_);
    return qr/^[^#]*$regex_str[^#]*$/;
}

my $number_args = $#ARGV + 1;
if ($number_args != 1) {
    print "Error: no input file specified.\n";
    exit;
}

my $filename = $ARGV[0];
open my $input, $filename or die "Could not open $filename: $!";
chomp(my @lines = <$input>);
close $input;

print sum(map {
    my ($line, $group_size_str) = split(" ", $_);
    my @group_sizes = split(",", $group_size_str);
    exhaustive_match_count($line, generate_regex_for_groups(@group_sizes))
} @lines);