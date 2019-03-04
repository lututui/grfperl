package GRFPerl::Table;

use strict;

use FindBin qw($RealBin);
use lib $RealBin;
use GRFPerl::FileEntry;
use GRFPerl::Constants qw(UINT32_SIZE UINT8_SIZE GRF_ENTRY_SETTINGS_UNPACK_SIZE GRF_HEADER_SIZE);

use Compress::Zlib qw(uncompress);
use Fcntl qw(SEEK_SET);
use File::Path qw(make_path);
use File::Basename qw(dirname);

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
		
		$self->{entries}->{$fileName} = GRFPerl::FileEntry->new(
			$fileName,
			unpack(
				"L3 C L", 
				substr($rawTable, $nameEndPos + 1, $nameEndPos + 1 + GRF_ENTRY_SETTINGS_UNPACK_SIZE)
			)
		);
		
		$rawTable = substr($rawTable, $nameEndPos + 1 + GRF_ENTRY_SETTINGS_UNPACK_SIZE);
	}
}

sub extractFiles {
	my ($self, $FH, @targetFiles) = @_;
	
	foreach my $target (@targetFiles) {
		if (exists $self->{entries}->{$target}) {
			my $entry = $self->{entries}->{$target};
			
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