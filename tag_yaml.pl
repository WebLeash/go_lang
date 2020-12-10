#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

# script to tag replace and build the component yaml file for the jenkins job. Values taken from git lab file.

my $filename = $ARGV[0]; #Template File.. component.templ
my $nginx_file="devops/nginx.conf";
my $branch = $ARGV[1];

if (not defined $filename) {
  die "Need name\n";
}

my $rspca = $ENV{'app'};
my $pii =  $ENV{'pii'};
my $tag =  $ENV{'tag'};
my $group =  $ENV{'group'};
my $component =  $ENV{'component'};
my $project = $ENV{'CI_PROJECT_NAME'};

print "project name = >$project<\n";


my @inputfiles=`find ./devops -name "*.templ"`;

my @nginx_config;
    open(my $fh, '<', $nginx_file) or die "cannot open file $nginx_file";
    {
        @nginx_config = <$fh>;
    }
    close($fh);

foreach my $template(@inputfiles)
{
    open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
    print "processing: $template \n";
    my @array=`cat $template`;
    foreach my $line(@array)
    {
        $line =~ s/!!app!!/$rspca/g; #Application
        $line =~ s/!!pii!!/$pii/g; # Pii data
        $line =~ s/!!tag!!/$tag/g; #tag for docker
        $line =~ s/!!component!!/$component/g; # journey
        $line =~ s/!!appGroup!!/$group/g;  #group
        $line =~ s/!!branch!!/$branch/g; 
        $line =~ s/!!project!!/$project/g;
        $line =~ s/!!tag_version!!/$tag/g;

        if ($line =~ /!!nginx-here!!/)
        {
            foreach my $ng(@nginx_config)
            {
                my $nginx_prefix = "            ";
                my $nginx_line = $nginx_prefix . $ng;
                $line = $nginx_line;
                print $fh "$line";
                print ">>$line<<";
            }
        }

        print $fh "$line";
        print "$line";
    }
    close $fh;
    my @suffixlist=();
    my $yaml_file = fileparse($template,@suffixlist);
    $yaml_file =~ s/\.templ/\.yaml/g;
    print "moving $filename --> $yaml_file\n";
    system("mv $filename  $yaml_file");

   
}

