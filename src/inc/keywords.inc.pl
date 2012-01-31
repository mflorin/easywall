use Socket;

# keywords: (table, op, chain, rules, target), (0-> add, 1-> replace)), (# of arguments);
%keywords = (
	"policy" => [["", "-P", "", "", ""], [0, 1, 0, 0, 0], [0, 0, 1, 0, 0]],
	"in" => [["", "-A", "INPUT", "", ""], [0, 1, 1, 0, 0], [0, 0, 0, 0, 0]],
	"forw" => [["", "-A", "FORWARD", "", ""], [0, 1, 1, 0, 0], [0, 0, 0, 0, 0]],
	"out" => [["", "-A", "OUTPUT", "", ""], [0, 1, 1, 0, 0], [0, 0, 0, 0, 0]],
	"prerouting" => [["", "-A", "PREROUTING", "", ""], [0, 1, 1, 0, 0], [0, 0, 0, 0, 0]],
	"postrouting" => [["", "-A", "POSTROUTING", "", ""], [0, 1, 1, 0, 0], [0, 0, 0, 0, 0]],
	"nat" => [["-t nat", "", "", "", ""], [1, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"snat" => [["-t nat", "-A", "POSTROUTING", "", "-j SNAT --to-source"], [1, 1, 1, 0, 1], [0, 0, 0, 0, 1]],
	"dnat" => [["-t nat", "-A", "PREROUTING", "", "-j DNAT --to-destination"], [1, 1, 1, 0, 1], [0, 0, 0, 0, 1]],
	"masq" => [["-t nat", "-A", "POSTROUTING", "", "-j MASQUERADE"], [1, 1, 1, 0, 1], [0, 0, 0, 0, 0]],
	"mangle" => [["-t mangle", "", "", "", ""], [1, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"proto" => [["", "", "", "-p", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"tcpflags" => [["", "", "", "--tcp-flags", ""], [0, 0, 0, 0, 0], [0, 0, 0, 2, 0]],
	"syn" => [["", "", "", "--syn", ""], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"tcpoption" => [["", "", "", "--tcp-option", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"mss" => [["", "", "", "--mss", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"dport" => [["", "", "", "--dport [op]", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"sport" => [["", "", "", "--sport [op]", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"mac" => [["", "", "", "-m mac --mac-source [op]", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"drop" => [["", "", "", "", "-j DROP"], [0, 0, 0, 0, 1], [0, 0, 0, 0, 0]],
	"reject" => [["", "", "", "", "-j REJECT"], [0, 0, 0, 0, 1], [0, 0, 0, 0,0]],
	"accept" => [["", "", "", "", "-j ACCEPT"], [0, 0, 0, 0, 1], [0, 0, 0, 0,0]],
	"iface" => [["", "", "", "-i", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1,0]],
	"oface" => [["", "", "", "-o", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1,0]],
	"ulog" => [["", "", "", "", "-j ULOG"], [0, 0, 0, 0, 1], [0, 0, 0, 0, 0]],
	"log" => [["", "", "", "", "-j LOG"], [0, 0, 0, 0, 1], [0, 0, 0, 0, 0]],
	"nlgroup" => [["", "", "", "", "--ulog-nlgroup"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"uprefix" => [["", "", "", "", "--ulog-prefix \"[arg1]\""], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"cprange" => [["", "", "", "", "--ulog-cprange"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"qthreshold" => [["", "", "", "", "--ulog-qthreshold"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"level" => [["", "", "", "", "--log-level"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"prefix" => [["", "", "", "", "--log-prefix \"[arg1]\""], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"tcp-seq" => [["", "", "", "", "--log-tcp-seq"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"tcp-opt" => [["", "", "", "", "--log-tcp-opt"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"ip-opt" => [["", "", "", "", "--log-tcp-opt"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],
	"mark" => [["-t mangle", "", "", "", "-j MARK --set-mark"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"tos" => [["-t mangle", "", "", "", "-j TOS --set-tos"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"ttl" => [["-t mangle", "", "", "", "-j TTL --ttl-set"], [0, 0, 0, 0, 0], [0, 0, 0, 0, 1]],
	"state" => [["", "", "", "-m state --state", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"limit" => [["", "", "", "-m limit --limit", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"burst" => [["", "", "", "--limit-burst", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]],
	"icmp-type" => [["", "", "", "--icmp-type", ""], [0, 0, 0, 0, 0], [0, 0, 0, 1, 0]]
);

my @fields = ("table", "op", "chain", "rules", "target");

%fixed_args = (
	"policy" => ["INPUT", "OUTPUT", "FORWARD"]
);

sub in_fixed_arg_list {
	my ($kw, $arg) = @_;
	my $tmparglist = $fixed_args{$kw};
	if ($#$tmparglist > 0) {
		foreach (@$tmparglist) {
			if ($arg eq $_) {
				return 1;
			}
		}
		return 0;
	} else {
		return 1;
	}
}

sub do_plain {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $sc = "-s ";
	my $word = $ptr_words->[$idx];
	if ($current_scope == 1) { $sc = "-d ";	}
	my $ptype = param_type($ptr_words->[$idx]);
	my $_sc = $sc;
	if ($ptype eq "broken") {
		syntax_error(current_file_name(), current_line_no(), "near '".$ptr_words->[$idx]."'");
	}
	if ($ptype eq "mac") { 
		if ($current_scope == 1) {
			syntax_error(current_file_name(), current_line_no(), "cannot specify mac addresses as destinations");
		}
		$_sc = "-m mac --mac-source "; 
	}

	if ($ptype eq "port" or $ptype eq "port_range") {
		my $_p = "";
		if (!check_required($idx, $ptr_words, "<", "proto")) {
			$_p = "-p ".$options{"default_proto"}." ";
		}
		if ($force_scope == 0) {
			$current_scope = $scope_keys{$options{"default_port_dir"}};
		}
		if ($current_scope == 1) {
			$_sc = "--dport ";
		} else {
			$_sc = "--sport ";
		}
		$_sc = $_p.$_sc;
	}

	if (($ptype eq "domain") or ($ptype eq "text")) {
		warning ("(".current_file_name()."::".current_line_no().") trying to resolve $word");
		if ($options{"resolver"} == 1) {
			($_name,$_aliases,$_addrtype,$_length,@_addrs) = gethostbyname($word);
			if (not defined $_name) {
				syntax_error(current_file_name(), current_line_no(), "cannot resolv $word");
			}
			if ($options{"get_ip"} == 1) {
				$word = inet_ntoa($_addrs[0]);
			}
		}
	}

	if ($operator ne "") {
		$ptr_ret->[3] .= $_sc."$operator ".$word." ";
	} else {
		$ptr_ret->[3] .= $_sc.$word." ";
	}
}

sub do_keyword {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $tmpret = 1;
	alter_rule($idx, $ptr_words, $ptr_ret);
	my $nargs = $keywords{$ptr_words->[$idx]}->[2];
	my $max = 0;
	for (my $j = 0; $j < 5; $j ++) {
			if ($max < $nargs->[$j]) { $max = $nargs->[$j];}
	}
	return $idx + 1 + $max;
}

# @words is "a" "b" "c" => @words = "a b" "c";
# this is done when encountering operators such as "!" 
# e.g.: "!" "20" "abc" becomes "! 20" "abc"
sub glue {
	my ($idx, $ptr_words) = @_;
	if ($idx >= $#$ptr_words) { return; }
	$ptr_words->[$idx] = $ptr_words->[$idx]." ".$ptr_words->[$idx + 1];
	foreach my $i ($idx+1..$#$ptr_words-1) {
		$ptr_words->[$i] = $ptr_words->[$i + 1];
	}
	$#$ptr_words --;
}

sub alter_rule {
	my ($idx, $ptr_words, $ptr_rule) = @_;
	my $kw = $ptr_words->[$idx];
	my $rules = $keywords{$kw}->[0];
	my $logical = $keywords{$kw}->[1];
	my $nargs = $keywords{$kw}->[2];
	for (my $i = 0; $i < 5; $i ++) {
		if ($logical->[$i] == 0) {
			if ($rules->[$i] ne "") {
				$ptr_rule->[$i] .= $rules->[$i]." ";
				$ptr_rule ->[$i] =~ s/\[op\]/$operator/g;
			}
		} else {
			$ptr_rule->[$i] = $rules->[$i]." ";
			$ptr_rule ->[$i] =~ s/\[op\]/$operator/g;
		}
		my $__nargs = $nargs->[$i];
		for (my $argc = 0; $argc < $__nargs; $argc ++) {
			if (!in_fixed_arg_list($kw, $ptr_words->[$idx + $argc + 1])) {
				my $tmparray = $fixed_args{$kw};
				my $tmpfixedarglist = join " ", @$tmparray;
				syntax_error(current_file_name(), current_line_no(), "$kw accepts only $tmpfixedarglist as parameters");
			}
			my $tmptype = word_type($ptr_words->[$idx + $argc + 1]);
			if ($tmptype ne "plain" and $tmptype ne "operator") {
				syntax_error(current_file_name(), current_line_no(), "$kw requires $__nargs ".(($__nargs>1)?"arguments":"argument"));
			}
			if ($tmptype eq "operator") {
				check_syntax($idx + $argc + 1, $ptr_words, $ptr_rule);
				#$ptr_rule->[$i] .= $ptr_words->[$idx + $argc + 1]." ";
				#$__nargs ++;
				glue ($idx + $argc + 1, $ptr_words);
				$argc --;
				next;
			} else {
				my $__tmparg = $ptr_words->[$idx + $argc + 1];
				my $__tmpargidx = $argc + 1;
				if ($ptr_rule->[$i] =~ /\[arg$__tmpargidx\]/) {
					$ptr_rule->[$i] =~ s/\[arg$__tmpargidx\]/$__tmparg/g;
				} else {
					$ptr_rule->[$i] .= $ptr_words->[$idx + $argc + 1]." ";
				}
			}
		}
	}
	return $ptr_rule;
}

1;
