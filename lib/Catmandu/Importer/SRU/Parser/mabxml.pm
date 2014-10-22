package Catmandu::Importer::SRU::Parser::mabxml;

#ABSTRACT: Package transforms SRU responses into Catmandu MAB2
our $VERSION = '0.06'; #VERSION

use Moo;
use MAB2::Parser::XML;
use Encode;

sub parse {
    my ( $self, $record ) = @_;

    my $xml = $record->{recordData};
    my $parser = MAB2::Parser::XML->new( $xml ); 
    return $parser->next();
}


1;

__END__

=pod

=head1 NAME

Catmandu::Importer::SRU::Parser::mabxml - Package transforms SRU responses into Catmandu MAB2

=head1 VERSION

version 0.06

=head1 SYNOPSIS

    my %attrs = (
        base => 'http://sru.gbv.de/gvk',
        query => '1940-5758',
        recordSchema => 'mabxml' ,
        parser => 'mabxml' ,
    );

    my $importer = Catmandu::Importer::SRU->new(%attrs);

=head1 DESCRIPTION

Each mabxml response will be transformed into the format defined by 
L<Catmandu::Importer::PICA>

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
