%acl_list;

sub do_acl {
    my ($idx, $ptr_words) = @_;
    if ($idx != 0) { fatal("cannot have `acl` inside a rule"); }
    my @words = @$ptr_words;
    my $aclname = $words[$idx+1];
    if ($aclname eq "") { fatal ("syntax error (empty acl)"); }
    my $argsidx = $idx + 2;
    my $args = join " ", @words[$argsidx..$#words];
    $acl_list{$aclname} .= "\n".$args;
}

sub build_acl {
	my ($input, @lnos) = @_;
	my $output;
	my @lines = split /\n/, $input;
	my @tmpline_no;
	$ln = 0;
	foreach (@lines) {
		s/^\s+//g; s/\s+$//g;
		my @kws = split /\s+/, $_;
		if ($kws[0] eq "acl") {
			do_acl(0, \@kws);
		} else {
			$output .= $_."\n";
			push @tmpline_no, $lnos[$ln];
		}
		$ln ++;
	}
#	@line_no = @tmpline_no;
	return ($output, @tmpline_no);
}

sub is_acl {
	my $word = shift;
	foreach (keys %acl_list) {
		if ($word eq $_) { return 1; }
	}
	return 0;
}

sub get_acl {
	my $aclk = shift;
	return split /\n/, $acl_list{$aclk};
}

sub pass_expand_acls {
	my ($input, $lnosptr) = @_;
	my @lines = split /\n/, $input;
	my @out;
	my $changed = 0;
	my $ln = 0;
	foreach (@lines) {
		my $original_line = $_;
		my @outtmp1 = ($original_line);
		my $tmpchanged = 1;
		my $prevln = $ln;
		my $tmplineno = $lnosptr->[$prevln];
		while ($tmpchanged == 1) {
			my @outtmp2;
			$tmpchanged = 0;
			foreach (@outtmp1) {
				my $orig2 = $_;
				my @kws = split /\s+/, $orig2;
				foreach (@kws) {
					my $kw = $_;		
					if (is_acl($kw)) {
						my $tmpacl = $kw;
						my @tmpacllist = get_acl($kw);
						my $tmpcounter = 0;
						foreach (@tmpacllist) {
							if ($_ eq "") { next; }
							if ($tmpcounter > 0) {
								splice @$lnosptr,$prevln,0,$tmplineno;
								$ln++;
							}
							$changed = 1;
							$tmpchanged = 1;
							my $tmpline = $orig2;
							$tmpline =~ s/$tmpacl/$_/g;
							$tmpline =~ s/^\s+//g;
							$tmpline =~ s/\s+$//g;
							push @outtmp2, $tmpline;
							$tmpcounter ++;
						}
						last;
					}
				}
			}
			if ($tmpchanged == 1) { @outtmp1 = (@outtmp2); }
		}
		push @out, @outtmp1;
		$ln ++;
	}
	return ($changed, @out);
}

sub expand_acls {
	my ($input, @lnos) = @_;
	my @lines;
	my $changed = 1;
	while ($changed == 1) {
		($changed, @lines) = pass_expand_acls($input, \@lnos);
		$input = join "\n", @lines;
	}
	return ($input, @lnos);
}

1;
