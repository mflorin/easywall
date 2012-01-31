@runtime_stack = ();
%runtimes = (
    "run" => \&do_run
);

sub runtimestack_push {
	my ($a, $b) = @_;
	push @runtime_stack, [$a, $b];
}

sub do_runtime {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	$ptr_ret->[0] = "*".$ptr_words->[$idx];
	runtimestack_push($idx, join " ", @$ptr_words);
	return ($#$ptr_words + 1);
}

sub do_run {
    my ($idx, $ptr_words) = @_;
#	my @ptr_words = split /\s+/, $words;
    my @args = @$ptr_words[1..$#$ptr_words];
    info (0, "running ".green(@args));
    system(@args);
    if ($? == -1) {
        fatal("failed to execute @args");
    } elsif ($? & 127) {
        my $sig = $? & 127;
        my $core = ($? & 128)?"with":"without";
        fatal("child died with signal $sig, $core coredump");
    }
#    $rule_generated = 0;
#    return ($#$ptr_words + 1);
}

1;
