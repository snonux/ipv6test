# IPv6 Test Website

This is a quick and dirty Perl-based IPv6 test website.

## Running the Website

The website can be run using the Docker image in the `docker-image` directory.
Build it with `just build` there: it first builds the pinned Apache httpd base
from the official docker-library source (`just base`), then the CGI image.
Bump `VERSION` in the Justfile for every rebuild; pushed tags are immutable.

## Required Hosts Configuration

The website needs the following hosts configured (or similar hosts):

- `ipv6test.f3s.buetow.org` (IPv4 and IPv6)
- `ipv4.ipv6test.f3s.buetow.org` (IPv4 only)
- `ipv6.ipv6test.f3s.buetow.org` (IPv6 only)

## Try it out

* https://ipv6test.f3s.buetow.org
* https://ipv4.ipv6test.f3s.buetow.org
* https://ipv6.ipv6test.f3s.buetow.org
