#!/usr/bin/perl

# This is QUICK AND DIRTY!

use strict;
use warnings;

my $server_name = $ENV{SERVER_NAME} // 'ipv6test.f3s.buetow.org';

print <<END;
Content-type: text/html; charset=UTF-8

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>The Ultimate IPv6 Test Site</title>
</head>
<body>

<p>Congratulations, you have connected to a server that will display your method of connection, either IPv6 (preferred) or IPv4 (old and crusty). Well IPv6 is already ~15 years old either but not as old as IPv4 ;)</p>

<p>Nevertheless, please choose your destiny:</p>
<ul>
	<li><a href="https://ipv6test.f3s.buetow.org">ipv6test.f3s.buetow.org</a> for IPv6 & IPv4 Test (Dual Stack)</li>
	<li><a href="https://ipv4.ipv6test.f3s.buetow.org">ipv4.ipv6test.f3s.buetow.org</a> for IPv4 Only Test</li>
	<li><a href="https://ipv6.ipv6test.f3s.buetow.org">ipv6.ipv6test.f3s.buetow.org</a> for IPv6 Only Test</li>
</ul>
<p>If your browser times-out when trying to connect to this server then you do not have an IPv6 or IPv4 path (depends on which test you are running) to the server. If your browser returns an error that the host cannot be found then the DNS servers you are using are unable to resolve the AAAA or A DNS record (depends on which test you are running again) for the server. If your browser is able to connect to the "IPv6 Only Test", yet using the "IPv6 & IPv4 Test" returns a page stating you are using IPv4, then your browser and/or IP stack in your machine are preferring IPv4 over IPv6. It also might be that your operating system supports IPv6 but your web-browser doesn't.</p>
END

if ($server_name =~ /^ipv6test\.f3s\.buetow\.org$/) {
	print "<h3>IPv6 & IPv4 Test Results (Dual Stack):</h3>\n";
} elsif ($server_name =~ /^ipv6\.ipv6test\.f3s\.buetow\.org$/) {
	print "<h3>IPv6 Only Test Results:</h3>\n";
} elsif ($server_name =~ /^ipv4\.ipv6test\.f3s\.buetow\.org$/) {
	print "<h3>IPv4 Only Test Results:</h3>\n";
} elsif ($server_name eq 'ipv6.buetow.org') {
	print "<h3>IPv6 & IPv4 Test Results:</h3>\n";
} elsif ($server_name eq 'test6.ipv6.buetow.org') {
	print "<h3>IPv6 Only Test Results:</h3>\n";
} elsif ($server_name eq 'test4.ipv6.buetow.org') {
	print "<h3>IPv4 Only Test Results:</h3>\n";
} else {
	print "<h3>Test Results:</h3>\n";
}

print "<pre>You are using <b>" . do {
	if ($ENV{REMOTE_ADDR} =~ /(?:\d+\.){3}\d/) {
		'IPv4'
	} else {
		'IPv6'
	}
} . "</b>\n";


sub html_escape {
    my $str = shift;
    $str =~ s/&/&amp;/g;
    $str =~ s/</&lt;/g;
    $str =~ s/>/&gt;/g;
    return $str;
}

chomp (my $remote = html_escape(`host $ENV{REMOTE_ADDR}`));
chomp (my $server = html_escape(`host $ENV{SERVER_ADDR}`));
chomp (my $server0 = html_escape(`host $ENV{SERVER_NAME}`));
chomp (my $digremote = html_escape(`dig -x $ENV{REMOTE_ADDR}`));
chomp (my $digserver = html_escape(`dig -x $ENV{SERVER_ADDR}`));
chomp (my $digserver0 = html_escape(`dig -t any $ENV{SERVER_NAME}`));

print <<END;
Client address: $ENV{REMOTE_ADDR}
Server address: $ENV{SERVER_ADDR}

<strong>Client address reverse DNS lookup:</strong>
$remote

<strong>Server address reverse DNS lookup:</strong>
$server

<strong>Server hostname DNS lookup:</strong>
$server0

<strong>Advanced client address reverse DNS lookup:</strong>
$digremote

<strong>Advanced server address reverse DNS lookup:</strong>
$digserver

<strong>Advanced server hostname DNS lookup:</strong>
$digserver0
</pre>
<hr />
<p>Thanks for visiting, please recommend this test to your friends and colleagues. Any comments go to <a href="https://paul.buetow.org">Paul Buetow</a>.</p>
</body>
</html>
END
