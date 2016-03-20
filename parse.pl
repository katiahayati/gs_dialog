use warnings;
use strict;
use HTML::TreeBuilder::XPath;
use Data::Dumper;
use JSON::PP;
#use HTML::Entities;

#binmode STDOUT, ':encoding(UTF-8)';

my @fns = @ARGV;

my @dialogs;

foreach my $fn (@fns) {
    print STDERR $fn, "\n";
    my $xp = HTML::TreeBuilder::XPath->new;

    $xp->parse_file($fn);

    my $dialog;

    my $title;
    if ($xp->exists('//div[@class="head2"]/p')) {
	$title = $xp->findnodes('//div[@class="head2"]/p')->[0]->as_trimmed_text;
    } elsif ($xp->exists('//p[@class="head2"]')) {
	$title = $xp->findnodes('//p[@class="head2"]')->[0]->as_trimmed_text;
    } elsif ($xp->exists('//div[@class="head1"]/p')) {
	$title = $xp->findnodes('//div[@class="head1"]/p')->[0]->as_trimmed_text;
    } elsif ($xp->exists('//p[@class="head1"]')) {
	$title = $xp->findnodes('//p[@class="head1"]')->[0]->as_trimmed_text;
    } elsif ($xp->exists('//div[@class="head1"]')) {
	$title = $xp->findnodes('//div[@class="head1"]')->[0]->as_trimmed_text;
    } elsif ($xp->exists('//div[@class="head2"]')) {
	$title = $xp->findnodes('//div[@class="head2"]')->[0]->as_trimmed_text;
    }
    
    if (not defined $title) {
	warn "No title found in $fn";
    }
    # trim
#    $title =~ s/^\s+//g;
#    $title =~ s/\s+$//g;
    $dialog->{title} = $title;
    
    # remove all <span class="dir">....</span> from doc
    foreach my $stage_directions ($xp->findnodes('//p/span[@class="dir"]'), $xp->findnodes('//span[@class="dir"]')) {
	$stage_directions->detach;
    }

    my @parsed_lines;
    
    # all p's that contain a <span class="dpart">
    # that works for every show EXCEPT princess ida
    my @lines = $xp->findnodes('//p[./span[@class="dpart"]]');
    if (@lines) {
	foreach my $line (@lines) {
	    # get the part name
	    my $part_name = $line->findvalue('span[@class="dpart"]');

	    # clean up part name
	    $part_name =~ s/^\s+//g;
	    $part_name =~ s/\s+$//g;
	    $part_name =~ s/\.//g;
	
	    # remove the part name from the line
	    foreach ($line->findnodes('span[@class="dpart"]')) { $_->detach };

	    my $line_obj = { part => $part_name, line => $line->as_trimmed_text };
	    push @parsed_lines, $line_obj;

	}
    } else {
	my @part_rows = $xp->findnodes('//tr[./td[@class="part"]]');
	my $previous_part;
	my @previous_lines;
	foreach my $row (@part_rows) {
	    my $part_name = $row->findnodes('td[@class="part"]')->[0]->as_trimmed_text;
	    if ($part_name !~ /\w/) {
		# continuation of the previous line, yay! omg
		$part_name = $previous_part;
	    }
		
	    $part_name =~ s/\.//g;
	    my $line = join " ", grep { /\w/ } map { $_->as_trimmed_text } $row->findnodes('td[@class="tlyric"]');
	    
	    if (not defined $previous_part or $part_name ne $previous_part) {
		if (@previous_lines) {
		    my $previous_line_obj = { part => $previous_part, line => join " ", @previous_lines };
		    push @parsed_lines, $previous_line_obj;
		}
		@previous_lines = ();
	    }

	    $previous_part = $part_name;
	    push @previous_lines, $line;
	}
	if (@previous_lines) {
	    my $previous_line_obj = { part => $previous_part, line => join " ", @previous_lines };
	    push @parsed_lines, $previous_line_obj;
	}	      

    }

    $dialog->{lines} = \@parsed_lines;
    push @dialogs, $dialog;
    
#    print Dumper(\@lines);

}

#print Dumper(\@dialogs);
print encode_json(\@dialogs);
    
