package Mojolicious::Plugin::JSONRPC2;

use warnings;
use strict;
use utf8;
use feature ':5.10';
use Carp;

use version; our $VERSION = qv('1.1.1');    # REMINDER: update Changes

# REMINDER: update dependencies in Build.PL
use Mojo::Base 'Mojolicious::Plugin';
use JSON::XS;
# to ensure callback runs on notification
use JSON::RPC2::Server 0.4.0;   ## no critic (ProhibitVersionStrings)

use constant TIMEOUT    => 5*60;    # sec
use constant HTTP_200   => 200;
use constant HTTP_204   => 204;
use constant HTTP_415   => 415;

my $Type = 'application/json';
my %HEADERS = (
    'Content-Type' => qr{\A\s*\Q$Type\E\s*(?:;|\z)}msi,
    'Accept' => qr{(?:\A|,)\s*\Q$Type\E\s*(?:[;,]|\z)}msi,
);


sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(jsonrpc2_headers => sub { return %HEADERS });

    $app->routes->add_shortcut(jsonrpc2     => sub { _shortcut('POST', @_) });
    $app->routes->add_shortcut(jsonrpc2_get => sub { _shortcut('GET',  @_) });

    return;
}

sub _shortcut {
    my ($method, $r, $path, $server) = @_;
    croak 'usage: $r->jsonrpc2'.($method eq 'GET' ? '_get' : q{}).'("/rpc/path", JSON::RPC2::Server->new)'
        if !(ref $server && $server->isa('JSON::RPC2::Server'));
    return $r->any([$method] => $path, [format => 0], sub { _srv($server, @_) });
}

sub _srv {
    my ($server, $c) = @_;

    if (($c->req->headers->content_type // q{}) !~ /$HEADERS{'Content-Type'}/ms) {
        return $c->render(status => HTTP_415, data => q{});
    }
    if (($c->req->headers->accept // q{}) !~ /$HEADERS{'Accept'}/ms) {
        return $c->render(status => HTTP_415, data => q{});
    }

    $c->res->headers->content_type($Type);
    $c->render_later;

    my $timeout = $c->stash('jsonrpc2.timeout') || TIMEOUT;
    $c->inactivity_timeout($timeout);

    my $request;
    if ($c->req->method eq 'GET') {
        $request = $c->req->query_params->to_hash;
        if (exists $request->{params}) {
            $request->{params} = eval { decode_json($request->{params}) };
        }
    } else {
        $request = eval { decode_json($c->req->body) };
    }

    $server->execute($request, sub {
        my ($json_response) = @_;
        my $status = $json_response ? HTTP_200 : HTTP_204;
        $c->render(status => $status, data => $json_response);
    });

    return;
}


1; # Magic true value required at end of module
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::JSONRPC2 - JSON RPC 2.0 over HTTP


=head1 SYNOPSIS

    use JSON::RPC2::Server;

  # in Mojolicious app
  sub startup {
    my $app = shift;
    $app->plugin('JSONRPC2');

    my $server = JSON::RPC2::Server->new();

    $r->jsonrpc2('/rpc', $server);
    $r->jsonrpc2_get('/rpc', $server)->over(headers => { $app->jsonrpc2_headers });


=head1 DESCRIPTION

L<Mojolicious::Plugin::JSONRPC2> is a plugin that allow you to handle
some routes in L<Mojolicious> app using JSON RPC 2.0 over HTTP protocol.

Implements this spec: L<http://www.simple-is-better.org/json-rpc/transport_http.html>.
The "pipelined Requests/Responses" is not supported yet.

=head1 INTERFACE

=over

=item $app->defaults( 'jsonrpc2.timeout' => 300 )

Configure timeout for RPC requests in seconds (default value 5 minutes).

=item $r->jsonrpc2($path, $server)

Add handler for JSON RPC 2.0 over HTTP protocol on C<$path>
(with C<< format=>0 >>) using C<POST> method.

RPC functions registered with C<$server> will be called only with their
own parameters (provided with RPC request) - if they will need access to
Mojolicious app you'll have to provide it manually (using global vars or
closures).

=item $r->jsonrpc2_get($path, $server_safe_idempotent)

B<WARNING!> In most cases you don't need it. In other cases usually you'll
have to use different C<$server> objects for C<POST> and C<GET> because
using C<GET> you can provide only B<safe and idempotent> RPC functions
(because of C<GET> semantic, caching/proxies, etc.).

Add handler for JSON RPC 2.0 over HTTP protocol on C<$path>
(with C<< format=>0 >>) using C<GET> method.

RPC functions registered with C<$server_safe_idempotent> will be called only with their
own parameters (provided with RPC request) - if they will need access to
Mojolicious app you'll have to provide it manually (using global vars or
closures).

=item $r->over(headers => { $app->jsonrpc2_headers })

You can use this condition to distinguish between JSON RPC 2.0 and other
request types on same C<$path> - for example if you want to serve web page
and RPC on same url you can do this:

    my $r = $app->routes;
    $r->jsonrpc2_get('/', $server)->over(headers=>{$app->jsonrpc2_headers});
    $r->get('/')->to('controller#action');

If you don't use this condition and plugin's handler will get request with
wrong headers it will reply with C<415 Unsupported Media Type>.

=back


=head1 OPTIONS

L<Mojolicious::Plugin::JSONRPC2> has no options.


=head1 METHODS

L<Mojolicious::Plugin::JSONRPC2> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register hooks in L<Mojolicious> application.


=head1 SEE ALSO

L<JSON::RPC2::Server>, L<Mojolicious>, L<MojoX::JSONRPC2::HTTP>.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.


=head1 SUPPORT

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-JSONRPC2>.
I will be notified, and then you'll automatically be notified of progress
on your bug as I make changes.

You can also look for information at:

=over

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-JSONRPC2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-JSONRPC2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-JSONRPC2>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-JSONRPC2/>

=back


=head1 AUTHOR

Alex Efros  C<< <powerman@cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Alex Efros <powerman@cpan.org>.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

