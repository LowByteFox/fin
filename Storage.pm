package Storage;

use Task;

sub open {
    my ($name) = @_;
    open(my $fh, "<", $name) or die "Could not open file '$name': $!";

    return $fh;
}

sub parse {
    my $line_count = 0;
    my @tasks;

    my ($fh) = @_;
    while (my $line = <$fh>) {
        $line_count++;
        chomp($line);
        next if $line =~ /^\s*$/;

        if ($line !~ /\|/) {
            print STDERR "Incorrectly formatted stored task at " .
                "line $line_count!";

            next;
        }

        my ($cron, $task) = split(/\|/, $line);
        push(@tasks, Task->new($task, $cron));
    }


    return @tasks;
}

sub close {
    my ($fh) = @_;
    close($fh);
}

1;
