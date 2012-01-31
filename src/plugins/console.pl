sub console_myname {
	return "Console Output";
}

sub console_init {
#	register_pluginkeyword("print", \&do_print);
#	register_pluginkeyword("info", \&do_info);
#	register_pluginkeyword("warning", \&do_warning);
	register_runtime("print", \&do_print);
	register_runtime("info", \&do_info);
	register_runtime("warning", \&do_warning);
}

sub do_print {
	my ($idx, $words) = @_;
	if ($idx != 0) {
		fatal("print must start a statment");
	}
	for (my $j = 1; $j <= $#$words; $j ++) {
		print $words->[$j]." ";
	}
	print "\n";
	$rule_generated = 0;
	return ($#$words + 1);
}

sub do_info {
	my ($idx, $words) = @_;
	info(0, join (" ",@$words[1..$#$words]));
	$rule_generated = 0;
	return ($#$words + 1);
}
sub do_warning {
	my ($idx, $words) = @_;
	warning(join (" ",@$words[1..$#$words]));
	$rule_generated = 0;
	return ($#$words + 1);
}

1;
