use warnings;
use strict;
use LWP::Simple;
use Data::Dumper;
my $show_fn = shift @ARGV or die "Usage: $0 <show fn>\n";

open IN, "$show_fn" or die $!;

while (<IN>) {
    chomp;
    my $show_name;
    my $base = $_;
    if (m|/gas/(.*?)/|) {
	$show_name = $1;
    }
    if (not defined $show_name) {
	warn "couldn't get show name for $_\n";
	next;
    }
#    mkdir $show_name;
    print STDERR $show_name, "\n";
    my $content = get($_);
    my @urls = map { s/.*a href="(.*?)".*/$1/; $_ } grep { /Dialogue/ and /<a href/ } split "\n", $content;
    foreach my $url (@urls) {
	print STDERR $url, "\n";
	my $dir = $base;
	$dir =~ s|(.*)/\w+.html|$1|;
	my $fetch = $dir . "/" . $url;
	print STDERR $fetch, "\n";
	getstore($fetch, "$show_name/$url");
    } 

#print STDERR Dumper(\@urls);
}
