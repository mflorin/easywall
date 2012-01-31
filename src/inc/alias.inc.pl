%aliases = ();

sub do_alias {
	my ($idx, $words, $rule) = @_;
	$aliases{$words->[$idx + 1]} = join " ",@$words[$idx+2..$#$words];

	$rule_generated = 0;
	return ($#$words + 1);
}

sub build_aliases {
	my $input = shift;
	my $ret;
	foreach (split /\n/, $input) {
		s/^\s+//g;
		s/\s+$//g;
		$line = $_;
		my @words = split / /;
		if ($words[0] eq "alias") {
			do_alias(0, \@words, undef);
		} else {
			$ret .= $line."\n";
		}
	}
	return $ret;
}

sub expand_aliases {
	my $input = shift;
	my $ret;
	foreach (split /\n/, $input) {
		s/^\s+//g;
		s/\s+$//g;
		$line = $_;
		my @words = split / /;
		foreach (@words) {
			my $word = $_;
			if (in_hash($word, %aliases)) {
				my $_alias = $aliases{$word};
				$line =~ s/$word/$_alias/g;
			}
		}
		$ret .= $line."\n";
	}
	return $ret;
}

sub expand_inline_aliases {
	my $input = shift;
	my @words = split / /, $input;
	foreach (@words) {
		my $word = $_;
		if (in_hash($word, %aliases)) {
			my $_alias = $aliases{$word};
			$input =~ s/$word/$_alias/g;
		}
	}
	return $input;
}

1;
