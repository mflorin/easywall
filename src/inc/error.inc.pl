sub fatal {
	my @args = @_;
	print " * FATAL ", @args, "\n";
	exit;
}

sub warning {
	my @args = @_;
	if ($options{"warnings"} == 1) {
		print " * WARNING ", @args, "\n";
	}
}

sub info {
	my @args = @_;
	print " * INFO ", @args, "\n";
}

1;
