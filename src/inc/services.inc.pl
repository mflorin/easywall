@services = ();

sub load_services {
	my $content = cat($options{"services"});
	foreach (split /\n/, $content) {
		if (/^#/) { next; }
		/(\S*)/;
		if ($1 ne "") {
			push @services, $1;
		}
	}
}

sub is_service {
	my $service = shift;
	foreach (@services) {
		if ($service eq $_) { return 1; }
	}
	return 0;
}

1;
