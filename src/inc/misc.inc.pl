sub cat {
	my ($len, $data);
	if ((-d @_[0]) || (!(-f @_[0]))) { 
		return ""; 
	}
	open(CAT, @_[0]);
	binmode(CAT);
	seek(CAT, 0, 2);
	$len=tell(CAT);
	seek(CAT, 0, 0);
	read(CAT, $data, $len);
	close(CAT);
	return $data;
}

sub in_hash {
    my ($word, %hash) = @_;
    foreach (keys %hash) {
        if ($word eq $_) { return 1; }
    }
    return 0;
} 
 
sub tryexec {
	my $retcode = system(@_);
	if ($retcode != 0) {
		fatal ("failed to execute ", @_);
	}
}
 
1;
