$DEBUG_LEVEL = 4;

$BAR_SIZE = 70;
$BAR_CHAR = "=";
$MSG_SIZE = 70;
$MSG_ROOT_CHAR = "+";
$DBG_ROOT_CHAR = "*";
$MSG_CHAR = "-";
$TAB_SIZE = 4;

sub red {
	my $txt = shift;
	return "\033[1;31m".$txt."\033[0m";
}
sub blue{
	my $txt = shift;
 	return "\033[1;35m".$txt."\033[0m";
}
sub green{
	my $txt = shift;
	return "\033[1;32m".$txt."\033[0m";
}
sub gray{
	my $txt = shift;
	return "\033[1;30m".$txt."\033[0m";
}

sub tab {
	my $i;
	for ($i = 0; $i < $TAB_SIZE; $i ++) {
		print " ";
	}
}
sub msgn {
	my ($level, @msg) = @_;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print gray($MSG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print gray($MSG_CHAR), " ";
    }
    print @msg, "\n";
}

sub msg {
	my ($level, @msg) = @_;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print gray($MSG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print gray($MSG_CHAR), " ";
    }
	print @msg;
}

sub msgd {
	my ($level, @msg) = @_;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print gray($DBG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print gray($MSG_CHAR), " ";
	}
	print @msg;
	my $tlen = 0;
	for ($i = 0; $i <= $#msg; $i ++) {
		$tlen += length($msg[$i]);
	}
	for ($i = $tlen + $level * $TAB_SIZE; $i < $MSG_SIZE; $i ++) {
		print " ";
	}
}

sub done {
	my $level = shift;
	if ($level > $DEBUG_LEVEL) { return; }
	print "[ ",green("ok")," ]\n";
}

sub failed {
	my $level = shift;
	if ($level > $DEBUG_LEVEL) { return; }
	print "[ ",red("!!")," ]\n";
}

sub fatal {
	my (@msg) = @_;
	my $level = 0;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print " ",red($DBG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print red($MSG_CHAR), " ";
    }
    print red(@msg), "\n";
	exit 1;
}

sub info {
	if ($options{"info"} == 0) { return; }
	my ($level, @msg) = @_;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print " ",gray($MSG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print gray($MSG_CHAR), " ";
    }
    print @msg, "\n";
}

sub warning {
	if ($options{"warnings"} == 0) { return; }
	my (@msg) = @_;
	my $level = 0;
	my $i;
    if ($level > $DEBUG_LEVEL) { return; }
    if ($level == 0) {
        print " ",green($DBG_ROOT_CHAR), " ";
    } else {
        for ($i = 0; $i < $level; $i ++) {
            tab;
		}
        print green($MSG_CHAR), " ";
    }
    print green(@msg), "\n";
}

sub syntax_error {
	my ($filename, $lineno, $msg) = @_;
	fatal "[syntax error] ($filename\:\:$lineno): $msg";
}

1;
