use strict;
use warnings;
package Package::Reaper;
use 5.008;
# ABSTRACT: pseudo-garbage-collection for packages

use Carp ();
use Symbol ();

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
destroyed.

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

"You might be a king or a little street sweeper, but sooner or later you dance
with Package:Reaper.";
