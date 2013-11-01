package URI::BNode;

use 5.010;
use strict;
use warnings FATAL => 'all';

use base qw(URI);

use Carp ();
use Data::UUID::NCName ();

# lolol

# XXX i've been advised to switch this to Data::GUID::Any

BEGIN {
    eval { require Data::UUID::MT };
    if ($@) {
        undef $@;
        eval { require OSSP::uuid };
        if ($@) {
            undef $@;
            eval { require Data::UUID::LibUUID };
            if ($@) {
                undef $@;
                eval { require UUID::Tiny };
                if ($@) {
                    die 'Failed to load Data::UUID::MT, OSSP::uuid, ' .
                        'Data::UUID::LibUUID or UUID::Tiny.';
                }
                else {
                    *_uuid = sub () {
                        UUID::Tiny::create_uuid_as_string(&UUID::Tiny::UUID_V4)
                      };
                }
            }
            else {
                *_uuid = sub () { Data::UUID::LibUUID::new_uuid_string(4) };
            }
        }
        else {
            *_uuid = sub () {
                my $u = OSSP::uuid->new;
                $u->make('v4');
                $u->export('str');
            };
        }
    }
    else {
        our $UUIDGEN = Data::UUID::MT->new;
        *_uuid = sub () { $UUIDGEN->create_string };
    }
}

my $PN_CHARS_BASE = qr/[A-Za-z\N{U+00C0}-\N{U+00D6}}\N{U+00D8}-\N{U+00F6}
                           \N{U+00F8}-\N{U+02FF}\N{U+0370}-\N{U+037D}
                           \N{U+037F}-\N{U+1FFF}\N{U+200C}-\N{U+200D}
                           \N{U+2070}-\N{U+218F}\N{U+2C00}-\N{U+2FEF}
                           \N{U+3001}-\N{U+D7FF}\N{U+F900}-\N{U+FDCF}
                           \N{U+FDF0}-\N{U+FFFD}\N{U+10000}-\N{U+EFFFF}]+/x;

# from the turtle spec: http://www.w3.org/TR/turtle/#BNodes
my $BNODE = qr/^\s*(_:)?((?:$PN_CHARS_BASE|[_0-9])
                   (?:$PN_CHARS_BASE|[._0-9\N{U+00B7}
                           \N{U+0300}-\N{U+036F}\N{U+203F}-\N{U+2040}-]+)?
                   (?:$PN_CHARS_BASE|[_0-9\N{U+00B7}
                           \N{U+0300}-\N{U+036F}\N{U+203F}-\N{U+2040}-]+)?)
               \s*$/osmx;


=head1 NAME

URI::BNode - RDF blank node identifiers which are also URI objects

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    my $bnode = URI::BNode->new;

    print "$bnode\n"; # something like _:EH_kW827XQ6vvX0yF8YzRA

=head1 METHODS

=head2 new [$ID]

Creates a new blank node identifier. If C<$ID> is undefined or empty,
one will be generated using L<Data::UUID::NCName>. If C<$ID> has a
value, it must either begin with C<_:> or conform to the blank node
syntax from the Turtle spec. Other values, including other URIs, will
be passed to the L<URI> constructor.

=cut

sub new {
    my $class = shift;

    my $bnode = _validate(@_) if @_ == 1;
    return URI->new(@_) unless defined $bnode;

    bless \$bnode, $class;
}

sub _validate {
    my $val = shift;

    if (!defined $val or $val eq '' or $val eq '_:') {
        $val = Data::UUID::NCName::to_ncname(_uuid);
    }
    elsif (my ($scheme, $opaque) = ($val =~ $BNODE)) {
        $val = $opaque;
    }
    else {
        return;
    }

    "_:$val";
}

=head2 opaque [$NEWVAL]

Replace the blank node's value with a new one. This method will croak
if passed a C<$NEWVAL> which doesn't match the spec in
L<http://www.w3.org/TR/turtle/#BNodes>.

=cut

sub opaque {
    my $self = shift;
    if (@_) {
        my $val = _validate(@_);
        Carp::croak("Blank node identifier doesn't match Turtle spec");
        $$self = $val;
    }

    (split(/:/, $$self, 2))[1];
}

# dirty little scheme function
sub _scheme {
    return '_';
}

=head1 AUTHOR

Dorian Taylor, C<< <dorian at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-uri-bnode at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=URI-BNode>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc URI::BNode


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=URI-BNode>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/URI-BNode>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/URI-BNode>

=item * Search CPAN

L<http://search.cpan.org/dist/URI-BNode/>

=back


=head1 SEE ALSO

=over 4

=item L<URI>

=item L<Data::UUID::NCName>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Dorian Taylor.

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at
L<http://www.apache.org/licenses/LICENSE-2.0>.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


=cut

1; # End of URI::BNode
