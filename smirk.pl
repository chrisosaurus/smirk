#!/usr/bin/env perl
# Copyright 2013 Chris Hall <followingthepath at gmail d0t com>
# smirk is released under the terms of the MIT License
# see LICENSE or https://github.com/mkfifo/smirk/blob/master/LICENSE for details

use strict;
use warnings;
use File::Basename;
use Text::Markdown 'markdown'; # libtext-markdown-perl

####### CONFIGURATION ########
my $index_template_path = 'templates/index.html';
my $post_template_path = 'templates/post.html';
my $indir = 'content';
my $outdir = 'posts';

# post spaces to fill
my $post_title_marker = '<!-- POST TITLE -->';
my $post_content_marker = '<!-- POST CONTENT -->';
my $post_date_marker = '<!-- POST DATE -->';

# index spaces to fill
my $index_content_marker = '<!-- INDEX CONTENT -->';

# replace LINK, TITLE and DATE
#<li> <a href="post1.html">Title of first post <time class=post-date datetime="2013-08-14T00:00:00+00:00">(14Th August, 2013)</time></a> </li>
my $index_elem = '                <li> <a href="LINK">TITLE <time class=post-date>(DATE)</time></a> </li>';


###### WORK BEGINS HERE #######
unless( -d $indir ){
    die "Could not find content to use in dir '$indir', aborting\n";
}

if( -e $outdir and ! -d $outdir ){
    die "existing file '$outdir' set as output directory\n";
}
# remove any existing files
if( -d $outdir ){
    unlink glob "$outdir/*";
} else {
    mkdir($outdir) or die "Failed to create '$outdir' : $!\n";
}

my $fh;

my $index_template;
open( $fh, '<', "$index_template_path" ) or die "Failed to open '$index_template_path' : $!\n";
{
    local $/;
    $index_template = <$fh>;
}
close $fh;

my $post_template;
open( $fh, '<', "$post_template_path" ) or die "Failed to open '$index_template_path' : $!\n";
{
    local $/;
    $post_template = <$fh>;
}
close $fh;


###### PROCESS POSTS #####
my @posts;

for my $file ( reverse sort glob "$indir/*" ){
    my $base = basename $file;
    $base =~ s/\.md$//;

    my ($date, $title);
    if( $base =~ m/ ^ (?<date> \d\d\d\d \- \d\d \- \d\d ) \- (?<title> .* ) $ /x ){
        $date = $+{date};
        $title = $+{title};
        $title =~ s/\-/ /g;
        $title = ucfirst $title;
        if( $date eq '9999-99-99' ){
            print "skipping post '$title' as it has date '$date'\n";
            next;
        }
    } else {
        # error
        print "ERROR: '$base' failed to match expected format, skipping\n";
        next;
    }

    my $post = $post_template;

    my $content;
    open( $fh, '<', "$file" ) or die "Failed to open '$file' : $!\n";
    {
        local $/;
        $content = <$fh>;
    }
    close $fh;

    $content = markdown $content;

    my $opath = "$outdir/$base.html";
    # generate post content
    my $pc = $post_template;
    $pc =~ s/$post_title_marker/$title/g;
    $pc =~ s/$post_content_marker/$content/;
    $pc =~ s/$post_date_marker/$date/g;
    open( $fh, '>', "$opath" ) or die "Failed to open '$opath' : $!\n";
    print $fh $pc;
    close $fh;


    # add index element
    my $ie = $index_elem;
    $ie =~ s/TITLE/$title/;
    $ie =~ s/LINK/$opath/;
    $ie =~ s/DATE/$date/;
    push @posts, $ie;
}

####### GENERATE INDEX #######

my $index_content = join "<br />\n", @posts;
$index_template =~ s/$index_content_marker/$index_content/;
open( $fh, '>', 'index.html' ) or die "Failed to open 'index.html' : $!\n";
print $fh $index_template;
close $fh;

print "\nFinished\n";

