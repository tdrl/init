#!/bin/sh
eval 'exec perl -x $0 ${1+"$@"}'
  if 0;

#!perl -w
#line 7
#
# Script to uniquely add a new element to a PATH-style environment variable.

# Copyright Terran Lane 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2012

#################### Subroutines ####################

#
# Show a simple help message
#
sub show_help() {
  print <<EOF
addpath.pl: add items to a path-style variable
Usage: $0 [arg]* item*
Arguments:
  -s <str>	Use <str> as the original path string
  -v <env_var>	Take original path string from <env_var> environment variable
  -f <char>	Use <char> as the item (field) separator
  -i <ifile>	Take items to add from <ifile> (1 item per line)
  -F		Add new items at the front of the string
  -B		Add new items at the back of the string
  -x		Expand variable refs in items
  -h
  --help	Print this message and exit
EOF
}

#
# Get a list of items from a file
#
sub items_from_file($) {
  my $fname=shift;
  my @ilist=();

  if (!open(IFILE,"< $fname")) {
    die("Can't open item file `$fname'...\n");
  }
  while (<IFILE>) {
    chomp;
    push(@ilist,$_);
  }
  close(IFILE);
  return @ilist;
}
  
#
# Remove non-unique elements from a list, preserving order.  Returns the
# new list
#
sub uniq(@) {
  my @work=@_;
  my $i=0;
  my %elts=();

  while ($i<=$#work) {
    if (!exists($elts{$work[$i]})) {
      $elts{$work[$i]}=1;
      ++$i;
    }
    else {
      splice(@work,$i,1);		# hack item out of middle
    }
  }
  return @work;
}

#################### Global Vars ####################

$envstr="";		# base environment string
@envlist=();		# split out version of above
$fieldsep=":";		# field separator
$to_front=1;		# which end to put them on
@newelts=();		# new elements to add
$do_vars=0;		# substitute env vars within items?

#################### Main Program ####################

# We do argument processing here by hand b/c (1) our needs are fairly
# simple and (2) we'd like to be able to skip expensive loading of
# external libraries.

for ($i=0;$i<=$#ARGV;++$i) {
  $arg=$ARGV[$i];
  if ($arg eq "-h" || $arg eq "--help") {
    show_help();
    exit(0);
  }
  if ($arg eq "-s") {
    $envstr=$ARGV[++$i];
    next;
  }
  if ($arg eq "-v") {
    $envstr=$ENV{$ARGV[++$i]} || "";
    next;
  }
  if ($arg eq "-f") {
    $fieldsep=$ARGV[++$i];
    next;
  }
  if ($arg eq "-i") {
    push(@newelts,items_from_file($ARGV[++$i]));
    next;
  }
  if ($arg eq "-F") {
    $to_front=1;
    next;
  }
  if ($arg eq "-B") {
    $to_front=0;
    next;
  }
  if ($arg eq "-x") {
    $do_vars=1;
    next;
  }
  # Everything else is thing to be added to path string...
  push(@newelts,$arg);
}

# Here we use a bit of regex magic to do the env variable substitutions...
# Note: we still don't handle the "~user" syntax, nor do we try to do the
# funky nested-brace expansion that csh does.
for ($i=0;$i<=$#newelts;++$i) {
  $newelts[$i]=~s/\$(\w+)|\$\{(\w+)\}/exists($ENV{$+})?$ENV{$+}:"\${$+}"/ge;
  $newelts[$i]=~s/\A(~(?=\/)|~\Z)/exists($ENV{HOME})?$ENV{HOME}:"\${HOME}"/e;
}

# Note that we have to quote regexp metachars here, or else the split may
# treat them as non-literals (e.g. "."), which is not what we want (also
# makes it symmetric w/ join()).
@envlist=split(/\Q$fieldsep/,$envstr);
if ($to_front) {
  unshift(@envlist,@newelts);
}
else {
  push(@envlist,@newelts);
  @envlist=reverse(@envlist);
}
@envlist=uniq(@envlist);
if (!$to_front) {
  @envlist=reverse(@envlist);
}
print join($fieldsep,@envlist);
