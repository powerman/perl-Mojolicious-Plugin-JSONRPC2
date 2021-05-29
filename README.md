[![Build Status](https://travis-ci.org/powerman/perl-Mojolicious-Plugin-JSONRPC2.svg?branch=master)](https://travis-ci.org/powerman/perl-Mojolicious-Plugin-JSONRPC2)
[![Coverage Status](https://coveralls.io/repos/powerman/perl-Mojolicious-Plugin-JSONRPC2/badge.svg?branch=master)](https://coveralls.io/r/powerman/perl-Mojolicious-Plugin-JSONRPC2?branch=master)

# NAME

Mojolicious::Plugin::JSONRPC2 - JSON-RPC 2.0 over HTTP

# VERSION

This document describes Mojolicious::Plugin::JSONRPC2 version v2.0.4

# SYNOPSIS

    use JSON::RPC2::Server;

    # in Mojolicious app
    sub startup {
        my $app = shift;
        $app->plugin('JSONRPC2');

        my $server = JSON::RPC2::Server->new();

        $r->jsonrpc2('/rpc', $server);
        $r->jsonrpc2_get('/rpc', $server)->requires(
            headers => { $app->jsonrpc2_headers }
        );

# DESCRIPTION

[Mojolicious::Plugin::JSONRPC2](https://metacpan.org/pod/Mojolicious::Plugin::JSONRPC2) is a plugin that allow you to handle
some routes in [Mojolicious](https://metacpan.org/pod/Mojolicious) app using JSON-RPC 2.0 over HTTP protocol.

Implements this spec: [http://www.simple-is-better.org/json-rpc/transport\_http.html](http://www.simple-is-better.org/json-rpc/transport_http.html).
The "pipelined Requests/Responses" is not supported yet.

# INTERFACE

## defaults

    $app->defaults( 'jsonrpc2.timeout' => 300 );

Configure timeout for RPC requests in seconds (default value 5 minutes).

## jsonrpc2

    $app->routes->jsonrpc2( $path, $server );

Add handler for JSON-RPC 2.0 over HTTP protocol on `$path`
(with `format=>0`) using `POST` method.

RPC functions registered with `$server` will be called only with their
own parameters (provided with RPC request) - if they will need access to
Mojolicious app you'll have to provide it manually (using global vars or
closures).

## jsonrpc2\_get

    $app->routes->jsonrpc2_get( $path, $server_safe_idempotent );

**WARNING!** In most cases you don't need it. In other cases usually you'll
have to use different `$server` objects for `POST` and `GET` because
using `GET` you can provide only **safe and idempotent** RPC functions
(because of `GET` semantic, caching/proxies, etc.).

Add handler for JSON-RPC 2.0 over HTTP protocol on `$path`
(with `format=>0`) using `GET` method.

RPC functions registered with `$server_safe_idempotent` will be called only with their
own parameters (provided with RPC request) - if they will need access to
Mojolicious app you'll have to provide it manually (using global vars or
closures).

## jsonrpc2\_headers

    $app->routes->requires(headers => { $app->jsonrpc2_headers });

You can use this condition to distinguish between JSON-RPC 2.0 and other
request types on same `$path` - for example if you want to serve web page
and RPC on same url you can do this:

    my $r = $app->routes;
    $r->jsonrpc2_get('/', $server)->requires(headers=>{$app->jsonrpc2_headers});
    $r->get('/')->to('controller#action');

If you don't use this condition and plugin's handler will get request with
wrong headers it will reply with `415 Unsupported Media Type`.

# OPTIONS

[Mojolicious::Plugin::JSONRPC2](https://metacpan.org/pod/Mojolicious::Plugin::JSONRPC2) has no options.

# METHODS

[Mojolicious::Plugin::JSONRPC2](https://metacpan.org/pod/Mojolicious::Plugin::JSONRPC2) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new);

Register hooks in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# SEE ALSO

[JSON::RPC2::Server](https://metacpan.org/pod/JSON::RPC2::Server), [Mojolicious](https://metacpan.org/pod/Mojolicious), [MojoX::JSONRPC2::HTTP](https://metacpan.org/pod/MojoX::JSONRPC2::HTTP).

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/powerman/perl-Mojolicious-Plugin-JSONRPC2/issues](https://github.com/powerman/perl-Mojolicious-Plugin-JSONRPC2/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software. The code repository is available for
public review and contribution under the terms of the license.
Feel free to fork the repository and submit pull requests.

[https://github.com/powerman/perl-Mojolicious-Plugin-JSONRPC2](https://github.com/powerman/perl-Mojolicious-Plugin-JSONRPC2)

    git clone https://github.com/powerman/perl-Mojolicious-Plugin-JSONRPC2.git

## Resources

- MetaCPAN Search

    [https://metacpan.org/search?q=Mojolicious-Plugin-JSONRPC2](https://metacpan.org/search?q=Mojolicious-Plugin-JSONRPC2)

- CPAN Ratings

    [http://cpanratings.perl.org/dist/Mojolicious-Plugin-JSONRPC2](http://cpanratings.perl.org/dist/Mojolicious-Plugin-JSONRPC2)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Mojolicious-Plugin-JSONRPC2](http://annocpan.org/dist/Mojolicious-Plugin-JSONRPC2)

- CPAN Testers Matrix

    [http://matrix.cpantesters.org/?dist=Mojolicious-Plugin-JSONRPC2](http://matrix.cpantesters.org/?dist=Mojolicious-Plugin-JSONRPC2)

- CPANTS: A CPAN Testing Service (Kwalitee)

    [http://cpants.cpanauthors.org/dist/Mojolicious-Plugin-JSONRPC2](http://cpants.cpanauthors.org/dist/Mojolicious-Plugin-JSONRPC2)

# AUTHOR

Alex Efros <powerman@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2014- by Alex Efros <powerman@cpan.org>.

This is free software, licensed under:

    The MIT (X11) License
