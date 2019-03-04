#!perl

package grf_extractor;

use strict;
use Compress::Zlib;
use Fcntl qw(SEEK_SET);

use FindBin qw($RealBin);
use lib "$RealBin/../";
use GRFPerl::Header;
use GRFPerl::FileEntry;
use GRFPerl::Table;
use GRFPerl::Constants qw(GRF_HEADER_SIZE UINT32_SIZE);

sub main {
	my ($grf, @targetFiles) = @_;
	
	die getUsage() if (not defined $grf or not $grf or not scalar @targetFiles);
	die "File not found: $grf" if (not -e $grf or not -f $grf);
	die "File is empty: $grf" if (-z $grf);
	
	open my $FH, "<:raw", $grf or die $!;
	die $! unless (read($FH, my $rawHeader, GRF_HEADER_SIZE) == GRF_HEADER_SIZE);
	
	my $header = GRFPerl::Header->new(unpack("a16 a14 L4", $rawHeader));
	
	die unsupportedOrCorrupted() unless (seek $FH, $header->{file_table_offset} + GRF_HEADER_SIZE, SEEK_SET);
	
	die unsupportedOrCorrupted() unless (read($FH, my $rawTableSize, 2 * UINT32_SIZE) == 2 * UINT32_SIZE);
	
	my $table = GRFPerl::Table->new(unpack("L2", $rawTableSize));
	
	die unsupportedOrCorrupted() unless (read($FH, my $rawTable, $table->{packed_size}) == $table->{packed_size});
	
	$table->buildEntries($rawTable);
	$table->extractFiles($FH, @targetFiles);
	
	close $FH;
}

main(@ARGV);

=pod
foreach my $entry (values %{$table->{entries}}) {
	seek $FH, GRF_HEADER_SIZE + $entry->{offset}, SEEK_SET;
	read $FH, my $packedFile, $entry->{packed_size};
	
	make_path(dirname($entry->{file_name}));
	
	open my $extracted, ">", $entry->{file_name};
	syswrite $extracted, uncompress($packedFile);
	close $extracted;
}
=cut

sub getUsage {
	die "TODO";
}

1;