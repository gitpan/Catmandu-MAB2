package MAB2::Parser::Disk;

# ABSTRACT: MAB2 RAW format parser
our $VERSION = '0.03'; # VERSION

use strict;
use warnings;
use charnames qw< :full >;
use Carp qw(croak);
use Readonly;

Readonly my $SUBFIELD_INDICATOR => qq{\N{INFORMATION SEPARATOR ONE}};
Readonly my $END_OF_FIELD       => qq{\n};
Readonly my $END_OF_RECORD      => q{};


# ToDo: use Moo

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
        filename   => undef,
        rec_number => 0,
        reader     => undef,
    };

    # check for file or filehandle
    my $ishandle = eval { fileno($file); };
    if ( !$@ && defined $ishandle ) {
        $self->{filename} = scalar $file;
        $self->{reader}   = $file;
    }
    elsif ( -e $file ) {
        open $self->{reader}, '<:encoding(UTF-8)', $file
            or croak "cannot read from file $file\n";
        $self->{filename} = $file;
    }
    else {
        croak "file or filehande $file does not exists";
    }
    return ( bless $self, $class );
}


sub next {
    my $self = shift;
    local $/ = $END_OF_RECORD;
    if ( my $data = $self->{reader}->getline() ) {
        $self->{rec_number}++;
        my $record = _decode($data);

        # get last subfield from 001 as id
        my ($id) = map { $_->[-1] } grep { $_->[0] =~ '001' } @{$record};
        return { _id => $id, record => $record };
    }
    return;
}


sub _decode {
    my $reader = shift;
    chomp($reader);

    my @record;

    my @fields = split($END_OF_FIELD, $reader);

    my $leader = shift @fields;
    if( $leader =~ m/^\N{NUMBER SIGN}{3}\s(\d{5}[cdnpu]M2.0\d{7}\s{6}\w)/xms ){
        push( @record, [ 'LDR', '', '_', $1 ] );
    }
    else{
        croak "record leader not valid: $leader";
    }

    # ToDo: skip faulty fields
    foreach my $field (@fields) {
        croak "incomplete field: \"$field\"" if length($field) <= 4;
        my $tag = substr( $field, 0, 3 );
        my $ind = substr( $field, 3, 1 );
        my $data = substr( $field, 4 );

        # check for a 3-digit numeric tag
        ( $tag =~ m/^[0-9]{3}$/xms ) or croak "Invalid tag: \"$tag\"";

        # check if indicator is an single alphabetic character
        ( $ind =~ m/^[a-z\s]$/xms ) or croak "Invalid indicator: \"$ind\"";

        # check if data contains subfields
        if ( $data =~ $SUBFIELD_INDICATOR ) {

            # check if data starts with a SUBFIELD_INDICATOR
            ( substr( $data, 0, 1 ) eq $SUBFIELD_INDICATOR ) or croak "Invalid subfield structure at: \"$tag$ind\"";
            my @subfields = split( $SUBFIELD_INDICATOR, substr( $data, 1 ) );
            ( @subfields ) or croak "no subfield data found: \"$tag$ind$data\"";
            push(
                @record,
                [   $tag,
                    $ind,
                    map { substr( $_, 0, 1 ), substr( $_, 1 ) } @subfields
                ]
            );
        }
        else {
            push( @record, [ $tag, $ind, '_', $data ] );
        }
    }
    return \@record;    
}

__END__

=pod

=head1 NAME

MAB2::Parser::Disk - MAB2 RAW format parser

=head1 VERSION

version 0.03

=head1 SYNOPSIS

L<MAB2::Parser::Disk> is a parser for MAB2-Diskette records.

L<MAB2::Parser::Disk> expects UTF-8 encoded files as input. Otherwise provide a 
filehande with a specified I/O layer.

Catmandu...

    use MAB2::Parser::Disk;

    my $parser = MAB2::Parser::Disk->new( $filename );

    while ( my $record_hash = $parser->next() ) {
        # do something        
    }

=head1 SUBROUTINES/METHODS

=head2 new

=head2 next()

Reads the next record from MAB2 input stream. Returns a Perl hash.

=head2 _decode()

Deserialize a raw MAB2 record to an array of field arrays.

1;    # End of MAB2::Parser::Disk

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
