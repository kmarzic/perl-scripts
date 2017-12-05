#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use HTTP::Daemon;
use threads;

sub process_client_requests
{
    my $c = shift;
    my $peer_addr = shift;

    STDOUT->autoflush(1);

    $c->daemon->close;  # close server socket in client

    printf ("Client connected ...\n");

    while( my $r = $c->get_request)
    {
        print ("Session info: ", $r->header('Host') . " " . $r->url->path() . " " . $r->uri . "\n");

        # my $path = $r->url->path();
        # print ("Path: $path\n");
        # $path = substr ($path, 1); #strip leading slash 
        # print ("Path: $path\n");

        if ($r->method eq "GET")
        {
            my $path = $r->url->path();
            $path = '.' . $path; # serve files from current directory
            $c->send_file_response($path) or die $!;
            # or do whatever you want here
        }
        if ($r->method eq "POST")
        {
            $c->send_response ("200 OK");
            # $c->send_response ("xyz");
        }
        else
        {
            print "unknown method ".$r->method."\n";
        }
    }

    $c->close;
}

## MAIN

my $d = HTTP::Daemon->new(LocalAddr => 'localhost', #$ARGV[0],
    LocalPort => 8888, # 80,
    # LocalPort => 8080, # 80,
    Reuse => 1,
    Listen => 20) || die $!;

print ("Web Server started, server address: ", $d->sockhost(), ", server port: ", $d->sockport(), "\n");

while (my ($c) = $d->accept)
{
    threads->create(\&process_client_requests, $c)->detach;
    $c->close;  # close client socket in server
}

## end
