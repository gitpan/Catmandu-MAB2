package Catmandu::MAB2;

# ABSTRACT: Catmandu modules for working with MAB2 data.
our $VERSION = '0.02'; # VERSION

use strict;
use warnings;


1; # End of Catmandu::MAB2

__END__

=pod

=head1 NAME

Catmandu::MAB2 - Catmandu modules for working with MAB2 data.

=head1 VERSION

version 0.02

=head1 CATMANDU MODULES

=over

=item * L<Catmandu::Importer::MAB2>

=item * L<Catmandu::Exporter::MAB2>

=item * L<Catmandu::Fix::mab_map>

=back

=head1 INTERNAL MODULES

=over

=item * L<MAB2::Parser::RAW>

=item * L<MAB2::Parser::XML>

=item * L<MAB2::Writer::RAW>

=item * L<MAB2::Writer::XML>

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Catmandu::MAB2

You can also look for information at:

    Catmandu
        https://metacpan.org/module/Catmandu::Introduction
        https://metacpan.org/search?q=Catmandu

    LibreCat
        http://librecat.org/tutorial/index.html

=head1 AUTHOR

Johann Rolschewski <rolschewski@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Johann Rolschewski.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
