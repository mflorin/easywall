require "$inc_path/log.inc.pl";

sub readfile {
	my ($filename, $content) = @_;
	my $out;
	my @stack;
	my $prefix;
	my $i1 = 0;
	my @last_read_line_no;
	my $current_line = 1;
	#$content =~ s/\n/ /g;
	my $in_comment = 0;
	my $prev_ch = "";
	for (my $i = 0; $i <= length($content); $i ++) {
		my $ch = substr($content, $i, 1);
		if ($ch eq "#" and $in_comment == 0) {
			$in_comment = 1;
			$i1 = $i + 1;
			next;
		}
		if ($ch eq "\n") {
			$current_line ++; 
			if ($in_comment == 1) {
				$in_comment = 0;
				$i1 = $i + 1;
				next;
			}
			if ($prev_ch ne ";" and $prev_ch ne "\s" and $prev_ch ne "{" and $prev_ch ne "}" and $prev_ch ne "\\" and $prev_ch ne "") {
				print "[$prev_ch]\n";
				syntax_error($filename, $current_line - 1, "missing semicolon");
			}
		}
		if ($in_comment == 1 and $ch ne "\n") {
			$i1 = $i + 1;
			next;
		}
		if ($ch eq "{") {
			push @stack, $prefix;
			my $str = substr($content, $i1, $i - $i1);
			$str =~ s/^\s+//g;
			$str =~ s/\s+$//g;
			$prefix .= " ".$str;
			$i1 = $i + 1;
		}
		if ($ch eq ";") {
			my $str = substr($content, $i1, $i - $i1);
			$str =~ s/^\s+//g;
			$str =~ s/\s+$//g;
			if ($str ne "") {
				$out .= $prefix." ".$str."\n";
				push @last_read_line_no, $current_line;
			}
			$i1 = $i + 1;
		}
		if ($ch eq "}") {
			if ($prefix eq "") { 
				syntax_error($filename,$current_line,"missplaced brace '}'");
			}
			$prefix = pop @stack;
			$i1 = $i + 1;
		}

		if ($ch =~ /[^\s]/ and $ch ne "\n") {
			$prev_ch = $ch;
		}
	}
	if ($prefix ne "") {
		syntax_error($filename,$current_line,"unexpected end of file");
		exit;
	}

	return ($out, @last_read_line_no);
}

1;
