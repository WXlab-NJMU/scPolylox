#!/usr/bin/perl -w
#
#########################################
# This file is part of RPBPBR
# 
# Author:
#   Xi Wang, Xi.Wang at dkfz.de
#
#########################################
#

use strict;
my $usage = "$0 <infile> <outfile>\n";
my $infile = shift || die $usage;
my $outfile = shift || die $usage;

my %len; # pb reads' length
my %pos2seg; 
open(IN, $infile) || die "Can't open $infile for reading!\n";
while(<IN>) { 
  chomp; 
  if(/^\@/) {
    next unless /^\@SQ/; 
    /SN:(.*)\tLN:(\d+)$/; 
    $len{$1} = $2; 
    next;
  }
  my @a = split; 
  my @b = split /|/, $a[0]; 
  my $seg = $a[1] & 0x10 ? $b[0] : $b[1]; 
  #print join "\t", ($a[2], $a[3], $seg), "\n";
  $pos2seg{$a[2]}{$a[3]} = $seg; 
}
close IN;

open(OUT, ">$outfile") || die "Can't open $outfile for writing!\n";
foreach my $pb (sort keys %pos2seg) { 
  print OUT $pb."\t"; 
  my %sub = %{$pos2seg{$pb}}; 
  my @pos = sort {$a<=>$b} keys %sub; 
  my $out; 
  if($pos[0] < 45) { 
    #$out = "5'-$sub{$pos[0]}"; 
    $out = "$sub{$pos[0]}";  #unhyphenated
  } else { 
    #$out = "5'-X-$sub{$pos[0]}";
    $out = "X$sub{$pos[0]}"; #unhyphenated
  }
  for(my $i=1; $i<@pos; $i++) {
    my $n = int(($pos[$i] - $pos[$i-1]) / 212 - 0.5);
    for(my $j=0; $j<$n; $j++) { 
      #$out .= "-X"; 
      $out .= "X";  #unhyphenated
    }
    #$out .= "-$sub{$pos[$i]}";
    $out .= "$sub{$pos[$i]}"; #unhyphenated
  }
  my $n = int(($len{$pb} - $pos[-1]) / 212 - 0.5);
  for(my $j=0; $j<$n; $j++) { 
    #$out .= "-X"; 
    $out .= "X";  #unhyphenated
  }
  #$out .= "-3'"; 
  #unhyphenated
  # check the 3' end
  #
  # check barcode whether valid
  my $len_val = &length_check($out, $len{$pb}) ? "Yes": "No";
  my $pos_val = &pos_check($out) ? "Yes": "No";

  print OUT $out."\t".$len{$pb}."\t".$len_val."\t".$pos_val."\n"; 
}
close OUT;



sub length_check {
  #my $length_tolerance = 5;
  #my $length_tolerance_frac = 0.02;
  my $insert_tolerance = 12;
  my $deletion_tolerance = 5;
  my %expr_len = (
    1 => 246,
    3 => 670,
    5 => 1094, 
    7 => 1518, 
    9 => 1942,
  );
  my $barcode_len = length($_[0]);
  my $fa_len = $_[1];
  return 0 unless (exists $expr_len{$barcode_len}); 
  #return 0 unless (($fa_len >= $expr_len{$barcode_len} * (1  - $length_tolerance_frac) && $fa_len <= $expr_len{$barcode_len} * (1 + $length_tolerance_frac)) || ($barcode_len == 9 && $fa_len >= $expr_len{$barcode_len} * (1  - $length_tolerance_frac)) );
  return 0 unless (($fa_len >= $expr_len{$barcode_len} - $deletion_tolerance) && ($fa_len <= $expr_len{$barcode_len} + $insert_tolerance));
  return 1;
}

sub uniq {
  my %seen;
  grep !$seen{$_}++, @_;
}

sub pos_check {
#  my %letter_map = (
#    A => 1,
#    B => 2,
#    C => 3,
#    D => 4,
#    E => 5,
#    F => 6,
#    G => 7,
#    H => 8,
#    I => 9,
#  );
  my $barcode = $_[0]; 
  $barcode =~ tr/ABCDEFGHI/123456789/;
  my @p = split //, $barcode;
  my @pu = uniq(@p);
  return 0 unless(scalar(@p) == scalar(@pu)); 
  for(my $i=0; $i<@p; $i++) { 
    my $tmp = $p[$i];
    return 0 if($tmp =~ /X/);
    #$tmp = $letter_map{$tmp} if($tmp =~ /[A-Z]/); 
    return 0 if($i % 2 == $tmp % 2);
  }
  return 1;
}

