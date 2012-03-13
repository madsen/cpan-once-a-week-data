#! /usr/bin/perl
#---------------------------------------------------------------------
# commit.pl
# Copyright 2012 Christopher J. Madsen
#
# Commit the release data to Git
#---------------------------------------------------------------------

use strict;
use warnings;
use 5.010;

use FindBin '$Bin';

use DateTime ();

#---------------------------------------------------------------------
# Make sure the files are there:

chdir $Bin or die $!;

my @files = map { "$_.csv"} qw(authors dists releases);

for (@files) { die "$_ not found\n" unless -e $_ }

#---------------------------------------------------------------------
# Find the last release date:

my $message;
{
  open my $in, '<:utf8', 'releases.csv' or die $!;

  my $date = 0;

  while (<$in>) {
    $date = $1 if /,(\d+)$/ and $1 > $date;
  }

  close $in;

  die "Can't find max release date" unless $date;

  $message = "Commit release data up to " .
      DateTime->from_epoch( epoch => $date )
              ->format_cldr('yyyy-MMM-dd HH:mm:ss');
}

#---------------------------------------------------------------------
# Commit the files:

system qw(git commit -m), $message, @files;

exit($? >> 8);
