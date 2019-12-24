#!perl

package grf_extractor2;

use strict;
use JSON::Tiny qw(decode_json);
use File::Copy qw();
use File::Path qw(make_path rmtree);
use File::Basename qw(dirname);
use Encode qw(encode decode);

use FindBin qw($RealBin);
use lib "$RealBin/../";
use GRFPerl::GRF;

sub main {
	my ($ragnarokRoot, $file, $server) = @_;
	
	open my $conf, "<", "$server.json" or die $!;
	print "Using $server config\n";
	my @conf = <$conf>;
	close $conf;
	
	$conf = join '', @conf;
	$conf = decode_json $conf;
	
	foreach my $op (@{$conf->{"operations"}}) {
		print "Read op $op\n";
		if ($op eq "extract_from_grf") {
			extract_from_grf($ragnarokRoot . '/' . $file, $conf->{$op});
		} elsif ($op eq "extract_from_root") {
			extract_from_root($ragnarokRoot, $conf->{$op});
		} elsif ($op =~ /^move_\d$/) {
			move($conf->{$op});
		} elsif ($op eq "remove_dirs") {
			remove_dirs($conf->{$op});
		} elsif ($op eq "run_parsers") {
			run_parsers($conf->{$op});
		} elsif ($op eq "apply_utf8") {
			apply_encoding($conf->{$op});
		} elsif ($op eq "remove_files") {
			remove_files($conf->{$op});
		} else {
			die "Unknown op: $op";
		}
	}
}

main(@ARGV);

sub extract_from_grf {
	my ($file, $targets) = @_;
	
	print "Extracting " . scalar(@{$targets}) . " files from $file\n";
	GRFPerl::GRF->build($file)->extract(@{$targets});
}

sub extract_from_root {
	my ($root, $targets) = @_;
	
	foreach my $t (@{$targets}) {
		make_path(dirname($t));
		File::Copy::copy $root . '/' . $t, $t;
	}
}

sub move {
	my ($targets) = @_;
	
	foreach my $t (keys %{$targets}) {
		make_path(dirname($targets->{$t}));
		File::Copy::move $t, $targets->{$t};
	}
}

sub remove_dirs {
	my ($targets) = @_;
	
	rmtree(@{$targets}, { safe => 0 });
}

sub run_parsers {
	my ($targets) = @_;
	
	system "lua " . $_ foreach (@{$targets});
}

sub apply_encoding {
	my ($targets) = @_;
	
	foreach my $f (keys %{$targets}) {
		print "$f\n";
		open my $fh, "<", $f;
		my @c = <$fh>;
		close $fh;
		
		open $fh, ">", $f;
		
		foreach (@c) {
			my $aux = decode($targets->{$f}, $_);
			$aux = encode("utf8", $aux);
			chomp $aux;
			$aux =~ s/ +$//;
			$aux =~ s/\t+$//;
			print $fh "$aux\n";
		}
		
		close $fh;
	}
}

sub remove_files {
	my ($targets) = @_;
	
	unlink foreach (@{$targets});
}

sub getUsage {
	die "TODO";
}

1;