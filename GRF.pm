package GRFPerl::GRF;

use strict;
use Fcntl qw(SEEK_SET);

use FindBin qw($RealBin);
use lib "$RealBin/../";

use GRFPerl::Header;
use GRFPerl::Table;
use GRFPerl::Constants qw(GRF_HEADER_SIZE UINT32_SIZE);

sub new {
	my ($class) = @_;
	
	die "Don't call new directly, call build instead";
}

sub _new {
	my ($class, $fileName) = @_;
	
	my $self = bless {
		name => $fileName,
	}, $class;
	
	return $self;
}

sub build {
	my ($class, $fileName) = @_;
	
	my $self = GRFPerl::GRF->_new($fileName);
	
	open $self->{_handle}, "<:raw", $self->{name} or die $!;
	
	$self->_makeHeader();
	$self->_makeTable();
	
	return $self;
}

sub DESTROY {
	my ($self) = @_;
	
	close $self->{_handle};
}

sub _makeHeader {
	my ($self) = @_;
	
	die $! unless read($self->{_handle}, my $rawHeader, GRF_HEADER_SIZE) == GRF_HEADER_SIZE;
	
	$self->{_header} = GRFPerl::Header->new(unpack("a16 a14 L4", $rawHeader));	
}

sub _makeTable {
	my ($self) = @_;
	
	die $! unless seek $self->{_handle}, $self->{_header}->{file_table_offset} + GRF_HEADER_SIZE, SEEK_SET;
	die $! unless read($self->{_handle}, my $rawTableSize, 2 * UINT32_SIZE) == 2 * UINT32_SIZE;
	
	$self->{_table} = GRFPerl::Table->new(unpack("L2", $rawTableSize));	
	
	die $! unless read($self->{_handle}, my $rawTable, $self->{_table}->{packed_size}) == $self->{_table}->{packed_size};
	
	$self->{_table}->buildEntries($rawTable);
}

sub extract {
	my ($self, @what) = @_;
	
	$self->{_table}->extractFiles($self->{_handle}, @what);
}

1;