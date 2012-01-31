%specials = (
	"port" => \&do_port,
	"load" => \&do_load,
	"options" => \&do_options,
	"need" => \&do_need,
	"alias" => \&do_alias,
);

sub do_special {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	my $func = $specials{$ptr_words->[$idx]};
	return &$func($idx, $ptr_words, $ptr_ret);
}

sub do_load {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	if ($idx != 0) {
		fatal("load cannot be part of a rule");
	}
	for (my $j = 1; $j <= $#$ptr_words; $j ++) {
		my $pluginname = $ptr_words->[$j];
		my $plugin_full_path = "";
		my @plugin_paths = split /\s/, $options{"plugin_path"};
		foreach my $ppath (@plugin_paths) {
			$plugin_full_path = "$ppath/$pluginname";
			if ( -f "$plugin_full_path.pl" and -r "$plugin_full_path.pl") {
				last;
			}
		}
		if ( -f "$plugin_full_path.pl" and -r "$plugin_full_path.pl") {
			do "$plugin_full_path.pl";
		} else {
			fatal("plugin $pluginname does not exist in ".$options{"plugin_path"});
		}
		my $initfunction = $pluginname."_init";
		if (defined &$initfunction) {
			&$initfunction();
		} else {
			warning("plugin $pluginname: init function not found");
		}
		my $_plugin_name_function = $pluginname."_myname";
		my $_plugin_registered_name;
		if (defined &$_plugin_name_function) {
			$_plugin_registered_name = &$_plugin_name_function();
		} else {
			$_plugin_registered_name = $pluginname;
		}
		info(0,blue($_plugin_registered_name)." plugin loaded");
	}
	$rule_generated = 0;
	return ($#$ptr_words + 1);
}

sub do_port {
	my ($idx, $ptr_words, $ptr_ret) = @_;
	if (word_type($ptr_words->[$idx + 1]) eq "operator") {
		glue($idx + 1, $ptr_words);
	}
	if ($force_scope == 0) {
		$current_scope = $scope_keys{$options{"default_port_dir"}};
	}
	if ($current_scope == 0) {
		$ptr_ret->[3] .= "--sport ".$ptr_words->[$idx + 1];
	} else {
		$ptr_ret->[3] .= "--dport ".$ptr_words->[$idx + 1];
	}

	return $idx + 2;
}

1;
