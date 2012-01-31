%plugin_keywords = ();

### PLUGIN API ################################################################

sub register_pluginkeyword {
	my ($keyword, $subaddr) = @_;
	if (defined $plugin_keywords{$keyword}) {
		fatal("plugin keyword $keyword already defined");
	}
	$plugin_keywords{$keyword} = $subaddr;
}

sub register_keyword {
	my ($keyword, $definition) = @_;
	if (defined $keywords{$keyword}) {
		fatal("keyword $keyword already defined");
	}
	$keywords{$keyword} = $definition;
}

sub register_special {
	my ($specialk, $function) = @_;
	if (defined $specials{$specialk}) {
		fatal("special keyword $specialk already defined");
	}
	$specials{$specialk} = $function;
}

sub register_operator {
	my ($opr, $function) = @_;
	if (defined $operators{$opr}) {
		fatal("operator $opr already defined");
	}
	$operators{$opr} = $function;
}

sub register_runtime {
	my ($rk, $function) = @_;
	if (defined $runtimes{$rk}) {
		fatal("runtime function $rk already defined");
	}
	$runtimes{$rk} = $function;
}

sub add_fixed_option {
	my ($opt, $arg) = @_;
	my $tmparray = $fixed_options{$opt};
	$tmparray->[$#$tmparray + 1] = $arg;
	$#$tmparray ++;
}

sub add_fixed_param {
	my ($k, $arg) = @_;
	my $tmparray = $fixed_args{$k};
	$tmparray->[$#$tmparray + 1] = $arg;
	$#$tmparray ++;
}

sub add_exclude {
	my ($kw, $excl) = @_;
	foreach my $_cat (@excludes) {
		foreach my $index (0..$#$_cat) {
			if ($_cat->[$index] eq $kw) {
				push @$_cat, $excl;
				return;
			}
		}
	}
}

sub add_syntax {
	my ($k, $definition) = @_;
	$syntax{$k}->[0] .= " ".$definition;
	if ( ! defined $syntax{$k}->[1]) {
		$syntax{$k}->[1] = undef;
	}
}

sub add_syntax_function {
	my ($k, $function) = @_;
	if (! defined $syntax{$k}->[0]) {
		$syntax{$k}->[0] = "";
	}
	$syntax{$k}->[1] = $function;
}

sub change_syntax {
	my ($k, $definition) = @_;
	$syntax{$k}->[0] = $definition;
	if (! defined $syntax{$k}->[1]) {
		$syntax{$k}->[1] = undef;
	}
}

sub _alter_rule {
    my ($zone, $replace, $def, $rule) = @_;
    if ($replace == 1) {
        $rule->[$zone] = $def;
    } else {
        $rule->[$zone] = $rule->[$zone]." ".$def;
    }
}

sub _table {
    my ($replace, $def, $rule) = @_;
    _alter_rule(0, $replace, $def, $rule);
}

sub _op {
    my ($replace, $def, $rule) = @_;
    _alter_rule(1, $replace, $def, $rule);
}
sub _chain {
    my ($replace, $def, $rule) = @_;
    _alter_rule(2, $replace, $def, $rule);
}
sub _rule {
    my ($replace, $def, $rule) = @_;
    _alter_rule(3, $replace, $def, $rule);
}
sub _action {
    my ($replace, $def, $rule) = @_;
    _alter_rule(4, $replace, $def, $rule);
}

###############################################################################


sub do_pluginkeyword {
	my ($idx, $words, $rule) = @_;
	my $subptr = $plugin_keywords{$words->[$i]};
	return &$subptr($idx, $words, $rule);
}

1;
