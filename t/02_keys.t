# -*-perl-*-

use strict;
use Test::More;
use Cache::Memcached::Tags;
use IO::Socket::INET;

my $testaddr = "127.0.0.1:11211";
my $msock = IO::Socket::INET->new(PeerAddr => $testaddr,
                                  Timeout  => 3);
if ($msock) {
    plan tests => 10;
} else {
    plan skip_all => "No memcached instance running at $testaddr\n";
    exit 0;
}

my $memd = Cache::Memcached->new({
    servers   => [ $testaddr ],
    namespace => "Cache::Memcached::Tags::t/$$/" . (time() % 100) . "/",
});


ok($memd->set("key1", "val1"), "set succeeded");

is($memd->get("key1"), "val1", "get worked");
ok(! $memd->add("key1", "val-replace"), "add properly failed");
ok($memd->add("key2", "val2", undef, "tag1", "tag2"), "add with tags worked");
is($memd->get("key2"), "val2", "get worked");

ok($memd->replace("key2", "val-replace"), "replace worked");
ok(! $memd->replace("key-noexist", "bogus"), "replace failed");

ok($memd->add_tags("key1", "tag1"), "add tags worked");

ok($memd->delete_by_tags("tag1", "tag2"), "delete by tags worked");

my $stats = $memd->stats;
ok($stats, "got stats");
is(ref $stats, "HASH", "is a hashref");

# also make one without a hashref
my $mem2 = Cache::Memcached->new(
                                 servers   => [ ],
                                 debug     => 1,
                                 );
ok($mem2->{debug}, "debug is set on alt constructed instance");
