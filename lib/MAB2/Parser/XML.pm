package MAB2::Parser::XML;

# ABSTRACT: MAB2 XML parser
our $VERSION = '0.03'; # VERSION

use strict;
use warnings;
use Carp qw<croak>;
use XML::LibXML::Reader;


# ToDo: use Moo

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
        filename   => undef,
        rec_number => 0,
        xml_reader => undef,
    };

    # check for file or filehandle
    my $ishandle = eval { fileno($file); };
    if ( !$@ && defined $ishandle ) {
        my $reader = XML::LibXML::Reader->new( IO => $file )
            or croak "cannot read from filehandle $file\n";
        $self->{filename}   = scalar $file;
        $self->{xml_reader} = $reader;
    }
    elsif ( -e $file ) {
        my $reader = XML::LibXML::Reader->new( location => $file )
            or croak "cannot read from file $file\n";
        $self->{filename}   = $file;
        $self->{xml_reader} = $reader;
    }
    else {
        croak "file or filehande $file does not exists";
    }
    return ( bless $self, $class );
}


sub next {
    my $self = shift;
    if ( $self->{xml_reader}->nextElement('datensatz') ) {
        $self->{rec_number}++;
        my $record = _decode( $self->{xml_reader} );
        my ($id) = map { $_->[-1] } grep { $_->[0] =~ '001' } @{$record};
        return { _id => $id, record => $record };
    }
    return;
}


sub _decode {
    my $reader = shift;
    my @record;

    # get all field nodes from MAB2 XML record;
    foreach my $field_node (
        $reader->copyCurrentNode(1)->getChildrenByTagName('feld') )
    {
        my @field;

        # get field tag number
        my $tag = $field_node->getAttribute('nr');
        my $ind = $field_node->getAttribute('ind') // '';
        
        # ToDo: textContent ignores </tf> and <ns>

        # Check for data or subfields
        if ( my @subfields = $field_node->getChildrenByTagName('uf') ) {
            push( @field, ( $tag, $ind ) );

            # get all subfield nodes
            foreach my $subfield_node (@subfields) {
                my $subfield_code = $subfield_node->getAttribute('code');
                my $subfield_data = $subfield_node->textContent;
                push( @field, ( $subfield_code, $subfield_data ) );
            }
        }
        else {
            my $data = $field_node->textContent();
            push( @field, ( $tag, $ind, '_', $data ) );
        }

        push( @record, [@field] );
    }
    return \@record;
}


1;

__END__

=pod

=head1 NAME

MAB2::Parser::XML - MAB2 XML parser

=head1 VERSION

version 0.03

=head1 SYNOPSIS

L<MAB2::Parser::XML> is a parser for MAB2 XML records.

L<MAB2::Parser::XML> expects UTF-8 encoded files as input. Otherwise provide a 
filehande with a specified I/O layer.

    use MAB2::Parser::XML;

    my $parser = MAB2::Parser::XML->new( $filename );

    while ( my $record_hash = $parser->next() ) {
        # do something        
    }

=head1 SUBROUTINES/METHODS

=head2 new

=head2 next()

Reads the next record from MAB2 XML input stream. Returns a Perl hash.

=head2 _decode()

Deserialize a MAB2 XML record to an array of field arrays.

=head1 SEEALSO

...

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
