package Package::Reaper;
use 5.008;
use warnings;
use strict;

use Carp ();
use Symbol ();

=head1 NAME

Package::Reaper - pseudo-garbage-collection for packages

=head1 VERSION

version 0.103

=cut

our $VERSION = '0.103';

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
  my $self = [ $package, 1 ];
  bless $self => $class;
}

=head2 package

  my $package = $reaper->package;

This method returns the package which will be reaped.

=cut

sub package {
  my $self = shift;
  Carp::croak "a reaper's package may not be altered" if @_;
  return $self->[0];
}

=head2 is_armed

  if ($reaper->is_armed) { ... }

This method returns true if the reaper is armed and false otherwise.  Reapers
always start out armed.  A disarmed reaper will not actually reap when
destroyed.

=cut

sub is_armed {
  my $self = shift;
  return $self->[1] == 1;
}

=head2 disarm

  $reaper->disarm;

This method disarms the reaper, so that it will not reap the package when it is
destoryed.

=cut

sub disarm { $_[0]->[1] = 0 }

=head2 arm

  $reaper->arm;

This method arms the reaper, so that it will reap its package when it is
destroyed.  By default, new reapers are armed.

=cut

sub arm { $_[0]->[1] = 1 }

sub DESTROY {
  my ($self) = @_;

  return unless $self->is_armed;

  my $package = $self->package;

  Symbol::delete_package($package);
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

"You might be a king or a little street sweeper, but sooner or later you dance
with Package:Reaper.";
