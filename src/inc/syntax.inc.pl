use Regexp::Common qw /net/;

# syntax definition: ["<" before, ">" after, "*" class] [custom sub or undef]
%syntax = (
	# logical or between the elements;
	"!" => ["<*port <*port_range <*mac <*ip <syn <dport <sport <src <dst <*text", undef],
	"dport" => [ "<*port <*port_range", undef],
	"sport" => [ "<*port <*port_range", undef],
	"port" => [ "<*port <*port_range", undef],
	"mac" => [ "<*mac", undef],
	"snat" => [ "<*ip <*ip_range <*ip_port", undef],
	"dnat" => [ "<*ip <*ip_range <*ip_port", undef]
);

%requirements = (
	"dport" => "<proto",
	"sport" => "<proto",
	"prefix" => ":log",
	"uprefix" => ":ulog"
);

@excludes = (
	["in", "out", "forw"],
	["accept", "drop", "reject", "log", "ulog"],
	["mac", "out", "postrouting"],
	["limit"]
);

sub param_type {
	my $param = shift;
	if (lc($param) =~ /$RE{net}{MAC}/) { return "mac"; }
	if ($param =~ /$RE{net}{IPv4}/) { return "ip"; }
	if (($param =~ /([0-9]{1,5})/) and ($param eq $1)) { return "port"; }
	if (($param =~ /([0-9]{1,5})\:([0-9]{1,5})/) and ($param eq "$1:$2")) { 
		if ($1 > $2) {
			syntax_error(current_file_name(), current_line_no(), "invalid port range");
		}
		return "port_range"; 
	}
	if (($param =~ /($RE{net}{IPv4})-($RE{net}{IPv4})/) and ("$1-$2" eq $param)) { return "ip_range"; }
	if (($param =~ /($RE{net}{IPv4})\:([0-9]{1,5})/) and ("$1-$2" eq $param)) { return "ip_port"; }

	if ($param =~ /:/) { return "broken"; }
	if ($param =~ /^\./) { return "broken"; }

	# check services for known port names
#	my $_tmp_command = "cat ".$options{"services"}." | grep -v \"^#\" | awk '{print $1}' | grep	$param";
#	my $_tmp = `$_tmp_command`;
#	if ($_tmp ne "") { return "port"; }
	if (is_service($param)) { return "port"; } # will return service in the future
	######

#	if ($param =~ /(?! )$RE{net}{domain}/) { return "domain"; }

	return "text";
}

sub find_exclude_cat {
	my $word = shift;
	my @ret;

	foreach my $_cat (@excludes) {
		my @cat = @$_cat;
		foreach (@cat) {
			if ($word eq $_) {
				return @cat;
			}
		}
	}
	
	return @ret;
}

sub check_excludes {
	my ($idx, $word, $ptr_words) = @_;
	my @cat = find_exclude_cat($word);
	foreach my $index (0..$#$ptr_words) {
		if ($index == $idx) { next; }
		foreach (@cat) {
			if ($ptr_words->[$index] eq $_) {
				return $ptr_words->[$index];
			}
		}
	}

	return "";
}

sub skip_ops_right {
	my ($ptr_words, $start) = @_;
	for (my $i = $start; $i <= $#$ptr_words; $i ++) {
		if (word_type($ptr_words->[$i]) ne "operator") {
			return $ptr_words->[$i];
		}
	}
	return "";
}

sub skip_ops_left {
	my ($ptr_words, $start) = @_;
	for (my $i = $start; $i >= 0; $i --) {
		if (word_type($ptr_words->[$i]) ne "operator") {
			return $ptr_words->[$i];
		}
	}
	return "";
}

sub check_required {
	my ($idx, $ptr_words, $dir, $w) = @_;
	my $start = 0;
	my $stop = $#$ptr_words;

	if ($dir ne "<" and $dir ne ">" and $dir ne ":") {
		return 1;
	}

	if ($dir eq "<") {
		$stop = $idx - 1;
	}
	if ($dir eq ">") {
		$start = $idx + 1;
	}

	foreach my $i ($start..$stop) {
		if ($ptr_words->[$i] eq $w) {
			return 1;
		}
	}
	return 0;
}

sub check_requirements {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $word = $ptr_words->[$idx];
	if (defined $requirements{$word}) {
		my @neighbours = split / /, $requirements{$word};
		foreach (@neighbours) {
			my $neigh = $_;
			# Treat require #######################
		#	if (substr($neigh, 0, 1) eq "r") {
				my $direction = substr($neigh, 0, 1);
				my $req_word;
				if (($direction eq ">") or ($direction eq "<") or ($direction eq ":")) {
					$req_word = substr($neigh, 1);
				}  else {
					$req_word = substr($neigh, 0);
				}
				if (!check_required($idx, $ptr_words, $direction, $req_word)) {
					my $errormsg = "\"".$req_word."\" required ";
					if ($direction eq "<") { $errormsg .= "before "; }
					if ($direction eq ">") { $errormsg .= "after "; }
					if ($direction eq ":") { $errormsg .= "by "; }
					$errormsg .= "\"$word\"";
					syntax_error(current_file_name(), current_line_no(), $errormsg);
				}
				next;
		#	}
			# end require   #######################
		}
	}
}

sub check_syntax {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $word = $ptr_words->[$idx];
	my $excl = check_excludes($idx, $word, $ptr_words);
	if ($excl ne "") {
		syntax_error(current_file_name(), current_line_no(), "cannot have both $word and $excl");
	}
	check_requirements($idx, $ptr_words, $ptr_ret);
	if (defined $syntax{$word}) {
		my @neighbours = split / /, $syntax{$word}->[0];
		foreach (@neighbours) {
			my $neigh = $_;

			my $direction = substr($neigh, 0, 1);
			if ($direction ne "<" and $direction ne ">") { next; }
			my $check_word;
			if ($direction eq "<") {
				$check_word = skip_ops_right($ptr_words, $idx + 1);
			}
			if ($direction eq ">") {
				$check_word = skip_ops_left($ptr_words, $idx - 1);
			}
			if (substr($neigh, 1, 1) eq "*") {
				my $wtype = param_type($check_word);
				my $check_type = substr($neigh, 2);
				if ($wtype eq $check_type) {
					return;
				}
			} else {
				if ($check_word eq substr($neigh, 1)) {
					return;
				}
			}
		}
		
		if (defined $syntax{$word}->[1]) {
			my $custom_function = $syntax{$word}->[1];
			my $ret = &$custom_function($idx, $ptr_words, $ptr_ret);
			if ($ret == 0) { 
				return; 
			}
		}
		my $error_message = "syntax error near $word";
		syntax_error(current_file_name(), current_line_no(),"$error_message");
	}
}

1;
