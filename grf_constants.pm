package grf_constants;

use strict;

use base qw(Exporter);

use constant GRF_MAGIC => "Master of Magic\0";

use constant UINT32_SIZE => 4;
use constant UINT8_SIZE => 1;
use constant GRF_MAGIC_SIZE => length GRF_MAGIC;
use constant GRF_KEY_SIZE => 14;
use constant GRF_HEADER_SIZE => GRF_MAGIC_SIZE + GRF_KEY_SIZE + 4 * UINT32_SIZE;

use constant GRF_ENTRY_SETTINGS_UNPACK => "L3 C L";
use constant GRF_ENTRY_SETTINGS_UNPACK_SIZE => 3 * UINT32_SIZE + UINT8_SIZE + UINT32_SIZE;

our @EXPORT_OK = qw(
	GRF_MAGIC
	UINT32_SIZE
	UINT8_SIZE
	GRF_MAGIC_SIZE
	GRF_KEY_SIZE
	GRF_HEADER_SIZE
	GRF_ENTRY_SETTINGS_UNPACK
	GRF_ENTRY_SETTINGS_UNPACK_SIZE
);

1;