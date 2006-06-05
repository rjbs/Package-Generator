package Package::Reaper;

use warnings;
use strict;

use Carp ();

=head1 NAME

Package::Reaper - pseudo-garbage-collection for packages

=head1 VERSION

version 0.100

 $Id: /my/cs/projects/pkg-gen/trunk/lib/Package/Generator.pm 4470 2006-04-15T16:52:21.725214Z rjbs  $

=cut

our $VERSION = '0.100';

=head1 SYNOPSIS

    use Package::Generator;
    use Package::Reaper;

    {
      my $package = Package::Generator->new_package;
      my $reaper  = Package::Reaper->new($package);
      ...
    }

    # at this point, $package stash has been deleted

=head1 DESCRIPTION

This module allows you to create simple objects which, when destroyed, delete a
given package.  This lets you approximate lexically scoped packages.

=head1 INTERFACE

=head2 new

  my $reaper = Package::Reaper->new($package);

This returns the newly generated package reaper.  When the reaper goes out of
scope and is garbage collected, it will delete the symbol table entry for the
package.

=cut

sub new {
  my ($class, $package) = @_;

  # Do I care about checking $package with _CLASS and/or exists_package?
  # Probably not, for now. -- rjbs, 2006-06-05
  my $self = \$package;
  bless $self => $class;
}

sub package {
  my ($self) = @_;
  return $$self;
}

sub DESTROY {
  my ($self) = @_;
  my $package = $self->package;

  no strict 'refs';

  my $stash_name = $package . '::';

  # First, remove symbols.  Needed?  I'm not sure! -- rjbs, 2006-06-05
  %$stash_name = ();

  my ($parent, $rest) = $stash_name =~ /^([:\w]*::)?(\w+::)$/;

  $parent = '::' unless defined $parent;

  delete $parent->{$rest};
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
