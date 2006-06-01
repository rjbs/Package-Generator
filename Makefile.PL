use strict;
use warnings;

use inc::Module::Install;

name          ('Package-Generator');
author        ('Ricardo Signes <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/Package/Generator.pm');

requires('Test::More'       => 0.00);
requires('Scalar::Util'     => 0.00);

WriteAll();
