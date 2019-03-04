package grf_table;

use strict;

use FindBin qw($RealBin);
use lib $RealBin;
use grf_file_entry;
use grf_constants qw(UINT32_SIZE UINT8_SIZE GRF_ENTRY_SETTINGS_UNPACK GRF_ENTRY_SETTINGS_UNPACK_SIZE);

use Compress::Zlib qw(uncompress);

sub new {
	my ($class, $packed_size, $unpacked_size) = @_;
	
	my $self = bless {
		packed_size => $packed_size,
		unpacked_size => $unpacked_size,
		entries => {},
	}, $class;
	
	return $self;
}

sub buildEntries {
	my ($self, $rawTable) = @_;
	
	$rawTable = uncompress($rawTable) or die "Unable to uncompress file table";
	
	while ($rawTable) {
		my ($nameEndPos, $fileName);
		
		die unsupportedOrCorrupted("During file table parsing") if (($nameEndPos = index($rawTable, "\0")) == -1);
		$fileName = substr($rawTable, 0, $nameEndPos) =~ s/\\/\//rg;
		
		$self->{entries}->{$fileName} = grf_file_entry->new(
			$fileName,
			unpack(
				GRF_ENTRY_SETTINGS_UNPACK, 
				substr($rawTable, $nameEndPos + 1, $nameEndPos + 1 + GRF_ENTRY_SETTINGS_UNPACK_SIZE)
			)
		);
		
		$rawTable = substr($rawTable, $nameEndPos + 1 + GRF_ENTRY_SETTINGS_UNPACK_SIZE);
	}
}

sub extractFiles {
	my ($self, @targetFiles) = @_;
	
	foreach my $target (@targetFiles) {
		if (exists $table->{entries}->{$target}) {
			my $entry = $table->{entries}->{$target};
			
			die unsupportedOrCorrupted() unless (seek $FH, GRF_HEADER_SIZE + $entry->{offset}, SEEK_SET);
			die unsupportedOrCorrupted() unless (read($FH, my $packedFile, $entry->{packed_size}) == $entry->{packed_size});
			
			make_path(dirname($entry->{file_name}));
	
			open my $extracted, ">:raw", $entry->{file_name} or die $!;
			syswrite $extracted, uncompress($packedFile);
			close $extracted;
		}
	}
}

1;