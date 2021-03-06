use warnings;
use strict;

my %replacements = (
    frederic => 'Flora',
    mabel => 'Marshall',
    ruth => 'Reg',
    edith => 'Edward',
    kate => 'Karl',
    isabel => 'Isaac',
    samuel => 'Samantha',
    he => 'she',
    she => 'he',
    him => 'her',
    her => 'him',
    his => 'her',
    her => 'his',
    hers => 'his',
    lad => 'lass',
    lass => 'lad',
    man => 'woman',
    woman => 'man',
    men => 'women',
    women => 'men',
    wife => 'husband',
    husband => 'wife',
    papa => 'mama',
    gentlemen => 'ladies',
    gentleman => 'lady',
    fathers => 'mothers',
    mothers => 'fathers',
    father => "mother",
    mother => "father",
    sons => 'daughters',
    daughters => 'sons',
    son => 'daughter',
    daughter => 'son',
    boy => 'girl',
    girl => 'boy',
    boys => 'girls',
    girls => 'boys',
    );

sub is_uc {
    my ($char) = @_;
    return (uc $char) eq $char;
}

# perlfaq6
sub preserve_case {
    my ($old, $new) = @_;
    my @old_letters = split "", $old;
    my @new_letters = split "", $new;
    if (is_uc($old_letters[0])) {
	$new_letters[0] = uc($new_letters[0]);
    } else {
	$new_letters[0] = lc($new_letters[0]);
    }
    return join "", @new_letters;
	   
}

local $/ = undef;

my $text = <>; # slurp

$text =~  s/\b(@{[join "|", keys %replacements]})\b/preserve_case($1, $replacements{lc($1)})/egi;

print $text;
