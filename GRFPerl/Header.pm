package GRFPerl::Header;

use strict;

sub new {
	my ($class, $magic, $key, $file_table_offset, $seed, $file_count, $version) = @_;
	
	my $self = bless {
		magic => $magic,
		key => $key,
		file_table_offset => $file_table_offset,
		seed => $seed,
		file_count => $file_count - $seed - 7,
		version => $version
	}, $class;
	
	return $self;
}

1;