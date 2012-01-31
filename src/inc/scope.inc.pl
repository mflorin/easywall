%scope_keys = (
	"src" => 0,
	"dst" => 1
);

sub do_scope {
	my ($idx, @words) = @_;
	my $kw = $words[$idx];
	$current_scope = $scope_keys{$kw};
	$force_scope = 1;
}

1;
