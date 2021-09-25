#!/usr/bin/perl -w
#
########################################
#
# File Name:
#   adapter_check_trim.pl
# 
# Description:
#   
# 
# Usage:
#   
# 
# Author:
#   Xi Wang, Xi.Wang@mdc-berlin.de
# 
# Date:
#   Wed Nov 18 17:04:21 CET 2015
#
########################################

use strict;
#my $usage = "$0 <input.fa> <adapter.mapping> <trimmed.fa> <remaining.fa> <chimeras.fa>\n";
my $usage = "$0 <input.fa> <adapter.mapping> <trimmed.fa>\n";
my $fafile = shift || die $usage;
my $infile = shift || die $usage;
my $outfile = shift || die $usage;
#my $outfile2 = shift || die $usage;
#my $outfile3 = shift || die $usage;

open(FA, $fafile) || die "Can't open $fafile for reading!\n";
my (%seq, $id); 
while(<FA>) { 
  chomp; 
  if(/^>/) {
    s/>//;
    $id = $_;
  } else { 
    if(exists $seq{$id}) { 
      $seq{$id} .= $_;
    } else { 
      $seq{$id} = $_;
    }
  }
}
close FA; 
#foreach $id (keys %seq) { print join "\t", ($id, $seq{$id}), "\n"; } 

open(IN, $infile) || die "Can't open $infile for reading!\n";
my (%adapter3, %adapter5, %adapter3_PAS, %read1, $rev_flag, $pos_left, $pos_right); 
while(<IN>) { 
  my @a = split; 
  $rev_flag = 0; 
  $rev_flag = 1 if($a[1] & 0x10); 
  $a[3] --; 
  $pos_left = $a[3]; 
  $pos_right = $a[3] + &cigar_len($a[5]);
  #unless($rev_flag) { 
  #  # shift pos to end of the adapter
  #  my $read_len_on_ref = &cigar_len($a[5]); 
  #  $a[3] += $read_len_on_ref; 
  #}
  if($a[0] =~ /adapter5/) {
    if($rev_flag) {
      push @{$adapter5{$a[2]}}, - $pos_left;
    } else {
      push @{$adapter5{$a[2]}}, $pos_right;
    }
  }
  if($a[0] =~ /adapter3/) {
    if($rev_flag) {
      push @{$adapter3{$a[2]}}, - $pos_right;
      push @{$adapter3_PAS{$a[2]}}, - $pos_left;
    } else {
      push @{$adapter3{$a[2]}}, $pos_left;
      push @{$adapter3_PAS{$a[2]}}, $pos_right;
    }
  }
  if($a[0] =~ /read1/) {
    if($rev_flag) { 
      push @{$read1{$a[2]}}, - $pos_right;
    } else {
      push @{$read1{$a[2]}}, $pos_left;
    }
  }
}
close IN;

open(OUT, ">$outfile") || die "Can't open $outfile for writing!\n";
#open(OUT2, ">$outfile2") || die "Can't open $outfile2 for writing!\n";
#open(OUT3, ">$outfile3") || die "Can't open $outfile3 for writing!\n";

foreach $id (keys %seq) { 
  unless(exists $adapter5{$id} || exists $adapter3{$id} || exists $read1{$id}) { 
    print join "\t", ($id, length($seq{$id}), 0), "\n";
    print "!!$id fail to find any adapters\n";
    #print OUT2 ">$id\n$seq{$id}\n"; 
    next;
  }
  # 5' - 3' - PAS - Read1
  my %adapter_at_pos; 
  foreach my $p (@{$adapter5{$id}}) {$adapter_at_pos{$p} = 5}; 
  foreach my $p (@{$adapter3{$id}}) {$adapter_at_pos{$p} = 3}; 
  foreach my $p (@{$adapter3_PAS{$id}}) {$adapter_at_pos{$p} = 2}; 
  foreach my $p (@{$read1{$id}}) {$adapter_at_pos{$p} = 1}; 
  my @pos =  sort {$a <=> $b} keys %adapter_at_pos; 
  print join "\t", ($id, length($seq{$id}), scalar(@pos));
  print "\t";
  print join ",", @pos, "\t";
  print join ",", @adapter_at_pos{@pos}, "\n";

  #####
  my $i; 
  my $found = 0; 
  for($i=0; $i<$#pos-2; $i++) { 
    if($adapter_at_pos{$pos[$i]} == 5 && $adapter_at_pos{$pos[$i+1]} == 3 && $adapter_at_pos{$pos[$i+2]} == 2 && $adapter_at_pos{$pos[$i+3]} == 1 &&  
      $pos[$i] * $pos[$i+1] > 0 && $pos[$i+1] * $pos[$i+2] > 0 && $pos[$i+2] * $pos[$i+3] > 0 && ($pos[$i+3] - $pos[$i+2]) >=30) {
      $found  = 1; 
      unless(($pos[$i+3] - $pos[$i+2]) <= 200) { 
        print "!!$id polyA too long (", $pos[$i+3] - $pos[$i+2], ") ";
        print join "\t", ($pos[$i+1] - $pos[$i], $pos[$i+2]-$pos[$i+1], $pos[$i+3] - $pos[$i+2]), "\n"; 
        next; 
      }
      my $clean_seq; 
      my $CI; 
      if($pos[$i] > 0) { ## donot need RC
        $clean_seq = substr($seq{$id}, $pos[$i], $pos[$i+1]-$pos[$i]);
        $CI = substr($seq{$id}, $pos[$i+3]-16, 16);
      } else { 
        my $tmp = reverse($seq{$id});
        $tmp =~ tr/ACGT/TGCA/;
        $tmp =~ tr/acgt/TGCA/;
        $clean_seq = substr($tmp, length($seq{$id})+$pos[$i], $pos[$i+1]-$pos[$i]);
        $CI = substr($tmp, length($seq{$id})+$pos[$i+3]-16, 16);
      }
      $CI =  &rc($CI); 
      if(&length_check($pos[$i+1] - $pos[$i])) {
        print join "\t", ("\$\$".$id, $CI, $pos[$i+1] - $pos[$i], $pos[$i+2]-$pos[$i+1], $pos[$i+3] - $pos[$i+2]), "\n"; 
        print OUT ">", $id, "/", $i, "_", $CI, "\n", $clean_seq, "\n";
      } else {
        print "!!$id Polylox length violent (", $pos[$i+1] - $pos[$i], ") ";
        print join "\t", ($pos[$i+1] - $pos[$i], $pos[$i+2]-$pos[$i+1], $pos[$i+3] - $pos[$i+2]), "\n"; 
      }
    }
  }
  unless($found) {
    print "!!$id fail to find concordant adapters\n";
  }
}
close OUT;

sub cigar_len { 
  my $cigar = $_[0]; 
  my $len = 0; 
  my $tmp; 
  while($cigar =~ /^(\d+)([NMID])/) {
    $len += $1 if($2 eq "M" || $2 eq "N" || $2 eq "D");
    $tmp="$1$2";
    $cigar =~ s/$tmp//;
  }
  return $len; 
}

sub rc {
  my $seq = reverse($_[0]);
  $seq =~ tr/ACGT/TGCA/;
  $seq =~ tr/acgt/TGCA/;
  return $seq;
}

sub length_check {
  my $len = $_[0];
  my $insert_tolerance = 12;
  my $deletion_tolerance = 5;
  #my $length_tolerance_frac = 0.02;
  my %expr_len = (
    246 => 1,
    670 => 3,
    1094 => 5,
    1518 => 7,
    1942 => 9,
  );
  for(my $i=($len - $insert_tolerance); $i<=($len + $deletion_tolerance); $i++) {
    return 1 if(exists $expr_len{$i});
  }
  return 0;
}

