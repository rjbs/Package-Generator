package Package::Generator;

use warnings;
use strict;

use Carp ();
use Scalar::Util ();

=head1 NAME

Package::Generator - generate new packages quickly and easily

=head1 VERSION

version 0.01

 $Id$

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Package::Generator;

    my $package = Package::Generator->new_package;
    ...

=head1 DESCRIPTION

This module lets you quickly and easily construct new packages.  It gives them
unused names and sets up their package data, if provided.

=head1 INTERFACE

=head2 new_package

  my $package = Package::Generator->new_package(\%arg);

This returns the newly generated package.  It can be called with no arguments,
in which case it just returns the name of a pristene package.  The C<base>
argument can be provided to generate the package under an existing namespace.
A C<make_unique> argument can also be provided; it must be a coderef which will
be passed the base package name and returns a unique package name under the
base name.

A C<data> argument may be passed as a reference to an array of pairs.  These
pairs will be used to set up the data in the generated package.  For example,
the following call will create a package with a C<$foo> set to 1 and a C<@foo>
set to the first ten counting numbers.

  my $package = Package::Generator->new_package({
    data => [
      foo => 1,
      foo => [ 1 .. 10 ],
    ]
  });

For convenience, C<isa> and C<version> arguments may be passed to
C<new_package>.  They will set up C<@ISA>, C<$VERSION>, or C<&VERSION>, as
appropriate.  If a single scalar value is passed as the C<isa> argument, it
will be used as the only value to assign to C<@ISA>.  (That is, it will not
cause C<$ISA> to be assigned;  that wouldn't be very helpful.)

=cut

my $i = 0;
sub new_package {
  my ($self, $arg) = @_;
  $arg->{base} ||= 'Package::Generator::__GENERATED__';
  $arg->{make_unique} ||= sub { sprintf "%s::%u", $arg->{base}, $i++ };

  my $package = $arg->{make_unique}->($arg->{base});
  # XXX: ensure that this name isn't yet defined in symbol tables?

  my @data = $arg->{data} ? @{ $arg->{data} } : ();

  push @data, (
    ($arg->{isa} ? (ISA => (ref $arg->{isa} ? $arg->{isa} : [ $arg->{isa} ]))
                 : ()),
    ($arg->{version} ? (VERSION => $arg->{version}) : ()),
  );

  $self->assign_symbols($package, \@data);

  return $package;
}

=head2 assign_symbols

  Package::Generator->assign_symbols($package, \@key_value_pairs);

This routine is used by C<L</new_package>> to set up the data in a package.

=cut

sub assign_symbols {
  my ($self, $package, $key_value_pairs) = @_;
  
  Carp::croak "list of key/value pairs must be even!" if @$key_value_pairs % 2;

  no strict 'refs';
  while (my ($name, $value) = splice @$key_value_pairs, 0, 2) {
    my $full_name = "$package\:\:$name";
    
    if (!ref($value) or Scalar::Util::blessed($value)) {
      ${$full_name} = $value;
    } else {
      *{$full_name} = $value;
    }
  }
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-package-generator@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically be
notified of progress on your bug as I make changes.

=head1 COPYRIGHT

Copyright 2006 Ricardo Signes, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
