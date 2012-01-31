sub find_file {
	my $filename = shift;
	my $retfile = "";
	if ( -f "./$file" and -r "./$file") {
		$retfile = "./$file";
	} else {
		# include path
		@paths = split /\s/, $options{"include_path"};
		foreach my $path (@paths) {
			my $tmpfile = "$path/$filename";
			if ( -f "$tmpfile" and -r "$tmpfile") {
				$retfile = $tmpfile;
			}
		}
	}
	return $retfile;
}
sub expand_includes {
    my ($filename, $input, @lnos) = @_;
    my $ret;
	my $lno = 0;
	my @locallnos;
    foreach (split /\n/, $input) {
        s/^\s+//g;
        s/\s+$//g;
        $line = $_;
        my @words = split /\s+/;
		if ($words[0] eq "include") {
			for (my $j = 1; $j <= $#words; $j ++) {
				my $file = find_file($words[$j]);
				if ($file eq "") {
					fatal("could not find ".$words[$j]." in \'".$options{"include_path"}."\'");
				}
				my ($tmpout, @tmplno) = readfile("$file", cat($file));
				my ($tmpret, @tmpexplineno)= expand_includes($file, $tmpout, @tmplno);
				push @locallnos, @tmpexplineno;
				$ret .= $tmpret;
			}
		} else {
	        $ret .= $line."\n";
			push @locallnos, "$filename|".$lnos[$lno];
		}
		$lno ++;
	}
	return ($ret, @locallnos);
}

1;
