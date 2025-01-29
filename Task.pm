package Task;

sub new {
    my ($class, $task, $cron) = @_;
    my $self = {
        task => $task,
        cron => $cron,
    };

    bless $self, $class;
    return $self;
}

sub get_task {
    my ($self) = @_;
    return $self->{task};
}

sub get_cron {
    my ($self) = @_;
    return $self->{cron};
}

1;
