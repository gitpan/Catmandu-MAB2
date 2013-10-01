package Catmandu::Exporter::MAB2;

#ABSTRACT: Package that exports MAB2 data
our $VERSION = '0.01'; #VERSION

use Catmandu::Sane;
use Catmandu::Util qw(xml_escape is_different);
use MAB2::Writer::RAW;
use MAB2::Writer::XML;
use Moo;

with 'Catmandu::Exporter';

has type => ( is => 'ro', trigger => \&_set_writer );
has xml_declaration => ( is => 'ro' );
has collection      => ( is => 'ro' );
has record          => ( is => 'ro', lazy => 1, default => sub {'record'} );
has writer          => ( is => 'ro' );

sub _set_writer {
    my ($self) = @_;
    my $writer;
    my $type = lc( $self->{type} );
    if ( $type eq 'raw' ) {
        $writer = MAB2::Writer::RAW->new( fh => $self->fh );
    }
    elsif ( $type eq 'xml' ) {
        $writer = MAB2::Writer::XML->new( fh => $self->fh );
    }
    else {
        croak('type not supported!');
    }

    $self->{writer} = $writer;
}

sub add {
    my ( $self, $data ) = @_;

    if ( !$self->count ) {
        if ( $self->xml_declaration and lc( $self->type ) eq 'xml' ) {
            $self->{writer}->start();
        }
    }

    $self->{writer}->write($data);

}

sub commit {
    my ($self) = @_;
    if ( $self->collection ) {
        $self->{writer}->end();
    }
    $self->{writer}->close_fh();

}


1;

__END__

=pod

=head1 NAME

Catmandu::Exporter::MAB2 - Package that exports MAB2 data

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    use Catmandu::Exporter::MAB2;
 
    my $exporter = Catmandu::Exporter::MAB2->new(file => "mab2.dat", type => "RAW");
    my $data = {
     record => [
        ...
        [245, '1', 'a', 'Cross-platform Perl /', 'c', 'Eric F. Johnson.'],
        ...
        ],
    };
 
    $exporter->add($data);
    $exporter->commit;

=head1 NAME

Catmandu::Exporter::MAB2 - serialize parsed MAB2 data

=head1 METHODS

=head2 new(file => $file, %options)

Create a new Catmandu MAB2 exports which serializes into a $file. Optionally
provide xml_declaration => 0|1 to in/exclude a XML declaration and, collection => 0|1
to include a MAB2 collection header.

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
