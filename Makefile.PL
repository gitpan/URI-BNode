use inc::Module::Install;

name        'URI-BNode';
all_from    'lib/URI/BNode.pm';
readme_from 'lib/URI/BNode.pm';
author      q{Dorian Taylor <dorian@cpan.org>};
license     'apache';

requires 'URI';
requires 'Data::GUID::Any';
requires 'Data::UUID::NCName';
requires 'URI::urn::uuid';

build_requires 'Test::More';

auto_install;

WriteAll;

