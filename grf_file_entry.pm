package grf_file_entry;

use strict;

sub new {
	my ($class, $file_name, $packed_size, $packed_size_aligned, $unpacked_size, $flags, $offset) = @_;
	
	my $self = bless {
		file_name => $file_name,
		packed_size => $packed_size,
		packed_size_aligned => $packed_size_aligned,
		unpacked_size => $unpacked_size,
		flags => $flags,
		offset => $offset,
	}, $class;
	
	return $self;
}

1;