%options = (
	"iptables" => "/sbin/iptables",
	"warnings" => 1,
	"info" => 1,
	"include_path" => "./ /home/mflorin/ /etc/conf.d/firewall/ /etc/conf.d/firewall/fw.d/",
	"plugin_path" => "/home/mflorin/private/work/bin/personals/firewall/plugins ./",
	"services" => "/etc/services",
	"resolver" => 0,
	"get_ip" => 0,
	"default_proto" => "tcp",
	"default_port_dir" => 1
);

%fixed_options = (
	"warnings" => ["yes", "no", "on", "off"],
	"info" => ["yes", "no", "on", "off"],
	"resolver" => ["yes", "no", "on", "off"],
	"default_proto" => ["tcp", "udp"],
	"default_port_dir" => \keys(%scope_keys)
);

sub check_fixed_option {
	my ($opt, $val) = @_;
	if ($fixed_options{$opt} eq "") { return 1; }
	my $ptr_valid_opt = $fixed_options{$opt};
	my @valid_opt = @$ptr_valid_opt;
	foreach (@valid_opt) {
		if ($_ eq $val) { return 1; }
	}

	return 0;
}

sub do_options {
	my ($idx, $words, $ret) = @_;
	if ($idx != 0) {
		fatal ("'options' must start a statement");
	}
	if ($#$words < 2) {
		syntax_error(current_file_name(), current_line_no(), "param required");
	}
	my $trailer = join " ", @$words[$idx+2..$#$words];
	if (!check_fixed_option($words->[$idx + 1], $trailer)) {
		my $_ptr_tmp_arglist = $fixed_options{$words->[$idx + 1]};
		my @_tmp_arglist = @$_ptr_tmp_arglist;
		my $_arglist = join " ", @_tmp_arglist;
		syntax_error(current_file_name(), current_line_no(), $words->[$idx + 1]." can only be '$_arglist'");
	}
	if (lc($trailer) eq "yes" || lc($trailer) eq "on" || lc($trailer) eq "1") {
		$options{$words->[$idx + 1]} = 1;
	} else {
		if (lc($trailer) eq "no" || lc($trailer) eq "off" || lc($trailer) eq "0") {
			$options{$words->[$idx + 1]} = 0;
		} else {
			$options{$words->[$idx + 1]} = join " ",@$words[$idx+2..$#$words];
		}
	}
	$rule_generated = 0;
	return ($#$words + 1);
}
