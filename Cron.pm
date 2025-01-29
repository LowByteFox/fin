package Cron;

use constant {
    NORMAL  => 1,
    MONTH   => 2,
    WEEK    => 3,
};

sub _simplify_term {
    my ($input, $mode) = @_;

    return $input if $mode == NORMAL;
    return $input if $input =~ /\d+/;
    return $input if $input eq "*";

    return 1 if ($mode == MONTH && $input =~ /jan/i);
    return 2 if ($mode == MONTH && $input =~ /feb/i);
    return 3 if ($mode == MONTH && $input =~ /mar/i);
    return 4 if ($mode == MONTH && $input =~ /apr/i);
    return 5 if ($mode == MONTH && $input =~ /may/i);
    return 6 if ($mode == MONTH && $input =~ /jun/i);
    return 7 if ($mode == MONTH && $input =~ /jul/i);
    return 8 if ($mode == MONTH && $input =~ /aug/i);
    return 9 if ($mode == MONTH && $input =~ /sep/i);
    return 10 if ($mode == MONTH && $input =~ /oct/i);
    return 11 if ($mode == MONTH && $input =~ /nov/i);
    return 12 if ($mode == MONTH && $input =~ /dec/i);

    return 0 if ($mode == WEEK && $input =~ /sun/i);
    return 1 if ($mode == WEEK && $input =~ /mon/i);
    return 2 if ($mode == WEEK && $input =~ /tue/i);
    return 3 if ($mode == WEEK && $input =~ /wed/i);
    return 4 if ($mode == WEEK && $input =~ /thu/i);
    return 5 if ($mode == WEEK && $input =~ /fri/i);
    return 6 if ($mode == WEEK && $input =~ /sat/i);
}

sub _simplify {
    my $output = "";
    my ($to_simplify, $in_mode) = @_;

    my ($pre, $step) = split(/\//, $to_simplify);

    if ($pre =~ /,/) {
        my @list = split(/,/, $pre);
        for my $li (@list) {
            if ($li =~ /-/) {
                my @range_list = split(/-/, $pre);
                for my $range_li (@range_list) {
                    $output = $output . _simplify_term($range_li, $in_mode) .
                        "-";
                }
                chop($output);
                next;
            }
            $output = $output . _simplify_term($li, $in_mode) . ",";
        }
        chop($output);
    } elsif ($pre =~ /-/) {
        my @list = split(/-/, $pre);
        for my $li (@list) {
            $output = $output . _simplify_term($li, $in_mode) . "-";
        }
        chop($output);
    } else {
        $output = _simplify_term($pre, $in_mode);
    }

    if ($step) {
        if ($step !~ /\d+/) {
            print STDERR "Step must be a number!\n";

            return "";
        }

        $output = $output . "/" . $step;
    }

    return $output;
}

sub _check_range {
    my ($in, $value) = @_;

    if ($in =~ /^(\d+)-(\d+)$/) {
        return $value >= $1 && $value <= $2;
    }

    return $in == $value;
}

sub _cron_match {
    my ($expr, $value) = @_;

    return 1 if $expr eq "*";

    my ($expr, $step) = split(/\//, $expr);

    if ($expr =~ /,/) {
        if ($step) {
            return scalar grep { _check_range($_, $value) && $_ % $step == 0}
                split(/,/, $expr);
        }

        return scalar grep { _check_range($_, $value) } split(/,/, $expr);
    }

    if ($expr =~ /^(\d+)-(\d+)$/) {
        if ($step) {
            return ($value >= $1 && $value <= $2) && $expr & $step == 0;
        }
        return $value >= $1 && $value <= $2;
    }

    if ($step) {
        if ($expr =~ /\d+/) {
            return $value == $expr && $value % $step == 0;
        }
        return $value % $step == 0;
    }

    return $value == $expr;
}

sub match {
    my ($cron_str, @time) = @_;
    my ($min, $hour, $dom, $month, $dow) = split(/\s+/, $cron_str);

    my ($local_min, $local_hour, $local_dom, $local_month, $local_dow) =
        @time[1..4, 6];

    $min = _simplify($min, NORMAL);
    $hour = _simplify($hour, NORMAL);
    $dom = _simplify($dom, NORMAL);
    $month = _simplify($month, MONTH);
    $dow = _simplify($dow, WEEK);

    return _cron_match($min, $local_min) &&
        _cron_match($hour, $local_hour) &&
        _cron_match($dom, $local_dom) &&
        _cron_match($month, $local_month + 1) &&
        _cron_match($dow, $local_dow);
}
1;
