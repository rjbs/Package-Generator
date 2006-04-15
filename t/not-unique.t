#!perl -T
use strict;
use warnings;

use Test::More tests => 7;

BEGIN { use_ok('Package::Generator'); }

Package::Generator->new_package({
  make_unique => sub { return 'Totally::Not::Unique' },
});

# Now with that generated, let's try to generate it again.

eval {
  Package::Generator->new_package({
    make_unique => sub { return 'Totally::Not::Unique' },
  });
};

like(
  $@,
  qr/couldn't generate a pristene package/,
  "name collision (we MIHOP)",
);

sub seq {
  my $i = 0;
  sub { $i++ };
}

eval {
  my $S = seq;
  Package::Generator->new_package({
    make_unique => sub { sprintf "%s::%u", $_[0], $S->() },
  });
};

is($@, '', "no problem making table with 1");

eval {
  my $S = seq;
  Package::Generator->new_package({
    make_unique => sub { sprintf "%s::%u", $_[0], $S->() },
  });
};

like($@, qr/couldn't generate a pristene/, "but second attempt fails (good!)");

eval {
  my $S = seq;
  Package::Generator->new_package({
    max_tries   => 2,
    make_unique => sub { sprintf "%s::%u", $_[0], $S->() },
  });
};

is($@, '', "but an atempt with max_tries=2 is ok");

eval {
  my $S = seq;
  Package::Generator->new_package({
    max_tries   => 2,
    make_unique => sub { sprintf "%s::%u", $_[0], $S->() },
  });
};

like(
  $@,
  qr/couldn't generate a pristene/,
  "but next attempt with max_tries=2 fails (good!)",
);

eval {
  my $S = seq;
  Package::Generator->new_package({
    max_tries   => 3,
    make_unique => sub { sprintf "%s::%u", $_[0], $S->() },
  });
};

is($@, '', "but an atempt with max_tries=3 is ok");
