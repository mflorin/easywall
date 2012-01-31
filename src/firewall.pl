#!/usr/bin/perl

use Getopt::Std;

$plugin_path = "/home/mflorin/bin/firewall/plugins";
$inc_path = "/home/mflorin/bin/firewall/inc";

require "$inc_path/readfile.inc.pl";
require "$inc_path/parser.inc.pl";

getopts("xdcf:");

if ($opt_x) {
	msgd (1, "shutting down firewall");
	my $ipt = $options{"iptables"};
	`$ipt -F; $ipt -F -t nat; $ipt -X`;
	done(1);
	exit;
}

my $input;
if ($opt_f) {
	if (-f $opt_f and -r $opt_f) {
		$input = cat($opt_f);
	} else {
		fatal ("cannot open $opt_f");
	}
} else {
	while (<>) {
		$input .= $_;
	}
}
my ($tmpout, @rlno) = readfile("stdin", $input);
parse_options($tmpout);
load_services();
my ($tmp, @rlno2) = expand_includes("stdin", $tmpout, @rlno);
my ($tmp2, @tmplnos) = build_acl($tmp, @rlno2);
my ($output, @finallnos) = expand_acls($tmp2, @tmplnos);
my @ret;
@line_no = @finallnos;
@ret = parse_block($output, @ret);
makedep();

if ($opt_d) {
	print_rules(\@ret);
}
if ($opt_c) {
	info (0,"syntax OK");
} else {
	run_rules(\@ret);
}
