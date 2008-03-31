package AnyEvent::Semaphore;

use AnyEvent;
use Scope::Guard;

use strict;
use warnings;

our $VERSION = '0.00_01';

sub new {
  my ($class,$count) = @_;

  my $self = bless {},$class;

  $self->{count} = $count || 1;

  $self->{queue} = [];

  return $self;
}

sub down {
  my ($self) = @_;

  if ($self->{count} >= 1) {
    $self->{count}--;
  } else {
    my $c = AnyEvent->condvar;

    push @{ $self->{queue} } => $c;

    $c->wait;
  }

  return;
}

sub up {
  my ($self) = @_;

  my $c = shift @{ $self->{queue} };

  if ($c) {
    $c->broadcast;
  } else {
    $self->{count}++;
  }

  return;
}

sub count {
  my ($self) = @_;

  return $self->{count};
}

sub guard {
  my ($self) = @_;

  $self->down;

  return Scope::Guard->new (sub { $self->up });
}

1;

=pod

=head1 NAME

AnyEvent::Semaphore - AnyEvent based semaphores

=head1 SYNOPSIS

  use AnyEvent::Semaphore;

  my $s = AnyEvent::Semaphore->new;

  $s->down;

  # Do something fun
  
  $s->up;

=head1 DESCRIPTION

This module is an AnyEvent based implementation of counting semaphores
and is very similar to L<Coro::Semaphore> in the way it works.

It implements the following methods

=over 4

=item new ($count?)

Creates  the semaphore, with  the $count argument being optional. If a
$count is  specified, this is the number  of slots the  semaphore will
have. If not specified, it defaults to 1.

=item down

Decreases the semaphore count  by one. If the count is zero, this will
cause the method to block until a slot opens up in the semaphore.

=item up

Increases the semaphore count by one. If the slot count was zero, this
will wake up one blocker that was waiting for the semaphore.

=item count

Returns the current semaphore count.

=item guard

Calling this method will down the semaphore (And will  obviously block
if neccesary) and  return a  guard object. If this  guard object is in
some way destroyed, the semaphore is upped.

=back

=head1 ACKNOWLEDGEMENTS

=over 4

=item Marc Lehmann for writing L<AnyEvent>.

=back

=head1 SEE ALSO

=over 4

=item L<AnyEvent>

=item L<Coro>

=back

=head1 BUGS

Most software has bugs. This module probably isn't an exception. 
If you find a bug please either email me, or add the bug to cpan-RT.

=head1 AUTHOR

Anders Nor Berle E<lt>berle@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Anders Nor Berle.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

