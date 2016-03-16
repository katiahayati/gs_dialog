use warnings;
use strict;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use JSON::PP;
use HTML::Entities;

binmode STDOUT, ':encoding(UTF-8)';

my @fns = @ARGV;

my @dialogs;

foreach my $fn (@fns) {
    print STDERR $fn, "\n";
    my $xp = HTML::TreeBuilder::XPath->new;

    $xp->parse_file($fn);

    my $dialog;

    my $title = $xp->findnodes('//div[@class="head2"]/p')->[0]->as_trimmed_text;
    
    # trim
#    $title =~ s/^\s+//g;
#    $title =~ s/\s+$//g;
    $dialog->{title} = $title;
    
    # remove all <span class="dir">....</span> from doc
    foreach my $stage_directions ($xp->findnodes('//p/span[@class="dir"]')) {
	$stage_directions->detach;
    }

    my @parsed_lines;
    
    # all p's that contain a <span class="dpart">
    my @lines = $xp->findnodes('//p[./span[@class="dpart"]]');
    foreach my $line (@lines) {
	# get the part name
	my $part_name = $line->findvalue('span[@class="dpart"]');

	# clean up part name
	$part_name =~ s/^\s+//g;
	$part_name =~ s/\s+$//g;
	$part_name =~ s/\.//g;
	
	# remove the part name from the line
	foreach ($line->findnodes('span[@class="dpart"]')) { $_->detach };

	my $line_obj = { part => $part_name, line => decode_entities($line->as_trimmed_text) };
	push @parsed_lines, $line_obj;

    }

    $dialog->{lines} = \@parsed_lines;
    push @dialogs, $dialog;
    
#    print Dumper(\@lines);

}

print encode_json(\@dialogs);
    
