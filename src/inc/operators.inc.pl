%operators = (
	"!" => \&do_not
);

sub do_operator {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $func = $operators{$ptr_words->[$idx]};
	return &$func($idx, $ptr_words, $ptr_ret);
}

sub do_not {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	$operator = "!";
	return ($idx + 1);
}
