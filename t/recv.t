#!/usr/bin/perl -w
use strict;
use 5.010;
use Test::More tests => 5;
use Socket;
use autodie qw(socketpair);

my ($sock1, $sock2);
socketpair($sock1, $sock2, AF_UNIX, SOCK_STREAM, PF_UNSPEC);

my $buffer;
send($sock1, "xyz", 0);
my $ret = recv($sock2, $buffer, 2, 0);

use autodie qw(recv);

SKIP: {

	skip('recv() never returns empty string with socketpair emulation',3)
		if ($ret);

	is($buffer,'xy',"recv() operational without autodie");

	# Read the last byte from the socket.
	$ret = recv($sock2, $buffer, 1, 0);

	is($buffer,"z","recv() operational with autodie");
	is($ret,"","recv returns undying empty string for local sockets");
}

eval {
	# STDIN isn't a socket, so this should fail.
	recv(STDIN,$buffer,1,0);
};

ok($@,'recv dies on returning undef');

eval {
	use autodie qw(send);
	# STDIN isn't a socket, so this should fail.
	send(STDOUT,$buffer,1,0);
};

ok($@,'send dies on returning undef');