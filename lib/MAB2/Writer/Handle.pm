package MAB2::Writer::Handle;

# ABSTRACT: Utility class that implements a file and filehandle attribute to write to
our $VERSION = '0.01'; # VERSION

use strict;
use Moo::Role;
use Scalar::Util qw(blessed openhandle);
use Carp qw(croak);

has file => (
    is  => 'rw',
    isa => sub {
        croak 'expect file!' unless defined $_[0];
    },
    trigger => \&_set_fh,
);

has fh => (
    is  => 'rw',
    isa => sub {
        my $ishandle = eval { fileno( $_[0] ); };
        croak 'expect filehandle or object with method print!'
            unless !$@ and defined $ishandle
            or ( blessed $_[0] && $_[0]->can('print') );
    },
    default => sub { \*STDOUT }
);

sub _set_fh {
    my ($self) = @_;

    open my $fh, '>:encoding(UTF-8)', $self->file
        or croak 'could not open file!';
    $self->fh($fh);
}

sub close_fh {
    my ($self) = @_;

    close $self->{fh};
}

sub write {
    my $self = shift;
    my $fh   = $self->fh;

    foreach my $record (@_) {
        $record = $record->{record} if ref $record eq 'HASH';
        $self->_write_record($record);
    }
}

1;

__END__

=pod

=head1 NAME

MAB2::Writer::Handle - Utility class that implements a file and filehandle attribute to write to

=head1 VERSION

version 0.01

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut