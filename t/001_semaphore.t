use Coro;
use Test::More;

use strict;
use warnings;

plan tests => 9;

use_ok 'AnyEvent::Semaphore'; 

my $s = AnyEvent::Semaphore->new;

isa_ok $s,'AnyEvent::Semaphore';

is $s->count,1,'default count';

is AnyEvent::Semaphore->new (42)->count,42,'specified count';

$s->down;

is $s->count,0,'downed count';

my $i = 1;

async {
  $s->down;

  $i = 0;
};

# To make damn sure :-)

cede for 1 .. 3;

is scalar @{ $s->{queue} },1,'queue';

is $i,1,'block';

$s->up;

cede;

is scalar @{ $s->{queue} },0,'queue empty';

is $i,0,'resume';

