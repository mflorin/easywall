@modules = ();
%procs = ();

sub need_module {
	my $module = shift;
	foreach (@modules) {
		if ($module eq $_) { return; }
	}
	push @modules, $module;
}

sub need_proc {
	my ($proc, $val) = @_;
	foreach (keys %procs) {
		if ($_ eq $proc and $procs{$_} eq $val) { return; }
	}
	$procs{$proc} = $val;
}

sub do_need {
	my ($idx, $words, $ret) = @_;
	if ($words->[$idx + 1] eq "module") {
		need_module($words->[$idx + 2]);
	}
	if ($words->[$idx + 1] eq "proc") {
		need_proc($words->[$idx + 2], $words->[$idx + 3]);
	}
	$rule_generated = 0;
	return ($#$words + 1);
}

sub makedep {
	foreach (@modules) {
		warning("loading module $_");
		`modprobe $_`;
	}
	foreach (keys %procs) {
		my $proc = $_;
		my $val = $procs{$_};
		`echo $val > $proc`;
		warning("$_ is now ".$procs{$_});
	}
}

1;
