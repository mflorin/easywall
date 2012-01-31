require "$inc_path/misc.inc.pl";
require "$inc_path/services.inc.pl";
require "$inc_path/includes.inc.pl";
require "$inc_path/options.inc.pl";
require "$inc_path/alias.inc.pl";
require "$inc_path/deps.inc.pl";
require "$inc_path/acl.inc.pl";
require "$inc_path/keywords.inc.pl";
require "$inc_path/scope.inc.pl";
require "$inc_path/specials.inc.pl";
require "$inc_path/operators.inc.pl";
require "$inc_path/runtime.inc.pl";
require "$inc_path/plugin.inc.pl";

$current_scope = 0;
$force_scope = 0;
$rule_generated = 1;
$current_line = 0;
@line_no = ();
@last_read_line_no = ();
$operator = "";

sub report_line_no {
	my ($filename, $lineno) = split /\|/, $line_no[$current_line];
	return "$filename line $lineno";
}

sub current_file_name {
	my ($filename, $lineno) = split /\|/, $line_no[$current_line];
	return $filename;
}

sub current_line_no {
	my ($filename, $lineno) = split /\|/, $line_no[$current_line];
	return $lineno;
}


sub emptyret {
	my $ret = shift;
	for (my $i = 0; $i < 5; $i ++) {
		if ($ret->[$i] ne "") { return 0;}
	}
	return 1;
}

sub word_type {
	my $word = shift;
	my @tmp = keys %keywords;
	if (in_hash($word, %keywords)) { return "keyword"; }
	if (in_hash($word, %specials)) { return "special"; }
	if (in_hash($word, %scope_keys)) { return "scope"; }
	if (in_hash($word, %operators)) { return "operator"; }
	if (in_hash($word, %runtimes)) { return "runtime"; }
	if (in_hash($word, %plugin_keywords)) { return "plugin"; }
	return "plain";
}

require ("$inc_path/syntax.inc.pl");

sub parse_block {
	my ($input, @rules) = @_;
	my @lines = split /\n/, $input;
	my @ret = @rules;
	$current_line = 0;
	foreach (@lines) {
		$rule_generated = 1;
		my $tmpret = parse_line(expand_inline_aliases($_));
		if ($rule_generated == 1) {
			if ($tmpret->[1] =~ /\-P/) {
				$tmpret->[4] =~ s/\-j//g; # ugly workaround
			} else {
				if ($tmpret->[1] eq "") { $tmpret->[1] = "-A"; }
				if ($tmpret->[2] eq "") { $tmpret->[2] = "INPUT"; }
				if ($tmpret->[4] eq "") { $tmpret->[4] = "-j ACCEPT"; }
			}
			push @ret, $tmpret;
		}
		$current_line ++;
	}

	return @ret;
}

sub get_words {
	my $line = shift;
	my @words;
	my $word = "";
	my $type1 = 0; # "
	my $type2 = 0; # '

	my $index = 0;
	my $ignore = 0;
	my $ignorenext = 0;
	foreach (0..length($line)) {
		$index = $_;
		my $ch = substr($line, $index, 1);
		if ($ch eq "\\") {
			$ignorenext = 1;
			next;
		}
		if ($ignorenext) {
			$word .= $ch;
			$ignorenext = 0;
			next;
		}
		if  ($ch eq "\"") { 
			my $prevch = ($index > 0)?(substr($line, $index - 1, 1)):"";
			my $nextch = ($index < length($line))?(substr($line, $index + 1, 1)):"";
			if (($prevch =~ /[^\s]/) and ($nextch =~ /[^\s]/)) {
				syntax_error(current_file_name(), current_line_no(), "missplaced \"");
			}
			if ($type2) {
				syntax_error(current_file_name(), current_line_no(), "missplaced \"");
			}
			$type1 = ($type1 == 0)?1:0;
			if ($type1 == 1) {
				$ignore = 1;
				next;
			} else {
				$ignore = 0;
				next;
			}
		}
		if ($ch eq "'") {
			$type2 = ($type1 == 0)?(($type2 == 0)?1:0):0;
			if ($type2 == 1) {
				$ignore = 1;
				next;
			} else {
				if ($type1 == 0) {
					$ignore = 0;
					next;
				}
			}
		}
		if ($ignore) {
			$word .= $ch; 
			next;
		}
		if ($ch =~ /[^\s]/) {
			$word .= $ch;
			next;
		} else {
			if ($word ne "") {
				push @words, $word;
				$word = "";
			}
		}
	}
	return @words;
}

sub parse_options {
	my $input = shift;
	my @lines = split /\n/, $input;
	foreach my $line (@lines) {
		my @tmpwords = get_words($line);
		if ($tmpwords[0] eq "options") {
			my $tmpret = parse_line(expand_inline_aliases($line));
		}
	}
	
}

sub parse_line {
	my $line = shift;
	my @ret = ("", "", "", "", "");
#	my @words = split /\s+/, $line;

	my @words = get_words($line);

	my $i = 0;
	while ($i <= $#words) {
		if ($words[$i] eq "") { $i ++; next; }
		my $j = parse_word($i, \@words, \@ret);
		$i = $j;
	}
	return \@ret;
}


sub parse_word {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	check_syntax($idx, $ptr_words, $ptr_ret);
	my $word = $ptr_words->[$idx];
	my $type = word_type($word);
	my $ret = $idx + 1;
	if ($type eq "special") { $ret = do_special($idx, $ptr_words, $ptr_ret); }
	if ($type eq "operator") { $ret = do_operator($idx, $ptr_words, $ptr_ret); }
	if ($type eq "keyword") { $ret = do_keyword($idx, $ptr_words, $ptr_ret); }
	if ($type eq "scope") { do_scope($idx, @$ptr_words); }
	if ($type eq "runtime") { $ret = do_runtime($idx, $ptr_words, $ptr_ret); }
	if ($type eq "plugin") { $ret = do_pluginkeyword($idx, $ptr_words, $ptr_ret); }
	if ($type eq "plain") { do_plain($idx, $ptr_words, $ptr_ret); }
	if ($type ne "scope" and $type ne "operator") {
		$force_scope = 0;
		$current_scope = 0;
		$operator = "";
	}
	return $ret;
}

sub print_rules {
	my $ptr_rules = shift;
	my $runtimecounter = 0;
	for (my $i = 0; $i <= $#$ptr_rules; $i ++) {
		if (!emptyret($ptr_rules->[$i])) {
			if (substr($ptr_rules->[$i]->[0], 0, 1) eq "*") {
				my $runtime_keyword = substr($ptr_rules->[$i]->[0], 1);
				my $tmpruntimefunction = $runtimes{$runtime_keyword};
				my $tmpidx = $runtime_stack[$runtimecounter]->[0];
				my $tmpargs = $runtime_stack[$runtimecounter]->[1];
				my @tmpptrwords = split /\s+/, $tmpargs;
				$runtimecounter ++;
				&$tmpruntimefunction($tmpidx, \@tmpptrwords);
			} else {
				print $options{"iptables"}," ";
				for (my $j = 0; $j < 5; $j ++) {
					print $ptr_rules->[$i]->[$j]." ";
				}
				print "\n";
			}
		}
	}
}

sub run_rules {
	my $ptr_rules = shift;
	my $runtimecounter = 0;
	if ($options{"clean"} == 1) {
		my $ipt = $options{"iptables"};
		tryexec("$ipt -F");
		tryexec("$ipt -F"); 
		tryexec("$ipt -F -t nat"); 
		tryexec("$ipt -F -t mangle"); 
		tryexec("$ipt -X");
	}
	for (my $i = 0; $i <= $#$ptr_rules; $i ++) {
		if (!emptyret($ptr_rules->[$i])) {
			if (substr($ptr_rules->[$i]->[0], 0, 1) eq "*") {
				my $runtime_keyword = substr($ptr_rules->[$i]->[0], 1);
				my $tmpruntimefunction = $runtimes{$runtime_keyword};
				my $tmpidx = $runtime_stack[$runtimecounter]->[0];
				my $tmpargs = $runtime_stack[$runtimecounter]->[1];
				my @tmpptrwords = split /\s+/, $tmpargs;
				$runtimecounter ++;
				&$tmpruntimefunction($tmpidx, \@tmpptrwords);
			} else {
				my $command = $options{"iptables"}." ";
				for (my $j = 0; $j < 5; $j ++) {
					$command .= $ptr_rules->[$i]->[$j]." ";
				}
				tryexec($command);
			}
		}
	}
}

1;
