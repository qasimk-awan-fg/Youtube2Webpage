#!/usr/bin/perl

use warnings;
use strict;
use autodie;
use FindBin qw($Bin);
use File::Copy qw(copy);
my $slug = shift @ARGV; 
my $url = shift @ARGV;

if (!$url || $url !~ m|^https://www.youtube.com|) {
	print STDERR "Usage:\n";
	print STDERR "$0 project-name \"https://www.youtube.com/watch?v=jNQXAC9IVRw\"\n";
	exit 1;
}


mkdir($slug);
chdir($slug);
my $video_file = `yt-dlp --console-title  --write-auto-subs --write-subs "$url" --print filename --no-simulate`;
chomp($video_file);
my ($vtt) = glob('*.vtt');
open(my $fh, "<", $vtt);
my $this_start = 0;
my $last_text_line = '';
my @timestamps;
my $out = "index.html";
-d  'images' || mkdir('images');

copy("$Bin/styles.css", "styles.css") or die "Cannot copy styles.css: $!";
copy("$Bin/viewer.js", "viewer.js") or die "Cannot copy viewer.js: $!";

open (my $outfile, ">", $out); 
print $outfile <<EOF;
<html>
<head>
 <link rel="stylesheet" type="text/css" href="styles.css" />
 <script src="viewer.js" defer></script>
 </head>
<body>


<h1>Youtube transcript</h1>
Source: <a href="@{[$url]}" target="_blank">@{[$url]}</a>

<ul>
EOF


my $timestamp_seen = 0;

while (my $line = <$fh>) {
	chomp $line;
	if (!$timestamp_seen) {
		if(  $line =~ /^\d\d:\d\d/ ) {
				$timestamp_seen = 1;
			} else {
			next;
		}
	}


		if ($line =~ /^\s*$/) { next}
		if ($line =~ /<\/c>$/) { next }
	if ($line =~ /(\d\d:\d\d:\d\d\.\d\d\d) --> (\d\d:\d\d:\d\d\.\d\d\d).*$/) {
		$this_start = $1;
		next;
	}
	if ($line eq $last_text_line) {
		next;
	}
	push @timestamps, $this_start;
	my $ts_filename = $this_start;
	$ts_filename =~ s/:/-/g;
	my $seconds;
	if ($this_start =~ /^(\d+):(\d+):(\d+)/) {
		my $hours = $1;
		my $minutes = $2;
		$seconds = $3;
		$seconds += $minutes  *60;
		$seconds += $hours * 3600;
	}

	print $outfile "<li>
	<div class=\"grab\"><img src=\"images/$ts_filename.jpg\" /></div><div class=\"subtitle\"><span id=\"$this_start\">$line</span>
<a href=\"@{[$url]}\&t=@{[$seconds]}\" target=\"blank\" class=\"videolink\">#</a>
	</div></li>\n";
	$last_text_line = $line;
}

print $outfile "
</ul>
</body>
</html>";
close($outfile);
close($fh);


gen_images (@timestamps);

sub gen_images {
	my @timestamps = @_;	
	my %seen;

	foreach my $timestamp (@timestamps) {
		next if $seen{$timestamp}++;
	my $ts_filename = $timestamp;
	$ts_filename =~ s/:/-/g;
		my $result = system(
			"ffmpeg", "-hide_banner", "-loglevel", "error", "-nostdin",
			"-ss", $timestamp, "-i", $video_file,
			"-frames:v", "1", "-q:v", "1", "-y",
			"images/$ts_filename.jpg"
		);
		die "Could not create image for $timestamp\n" if $result != 0;
	}

}
