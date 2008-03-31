use inc::Module::Install;

name 'AnyEvent-Semaphore';

all_from 'lib/AnyEvent/Semaphore.pm';

build_requires 'Coro'       => '4.45';
build_requires 'Test::More' => '0.72';

requires 'AnyEvent'     => '2.9';
requires 'Scope::Guard' => '0.03';

auto_install;

WriteAll;

