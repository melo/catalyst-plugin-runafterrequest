package Catalyst::Plugin::RunAfterRequest;

use strict;
use warnings;
use MRO::Compat;

our $VERSION = '1.000000';

sub run_after_request {
    my $self = shift;
    push( @{ $self->{run_after_request} ||= [] }, @_ );
}

sub finalize {
    my $self = shift;
    $self->next::method(@_);
    $self->_run_code_after_request;
}

sub _run_code_after_request {
    my $self = shift;
    $_->($self) for @{ $self->{run_after_request} || [] };
}

=head1 NAME

Catalyst::Plugin::RunAfterRequest - run code after the response has been sent.

=head1 SYNOPSIS

    #### In MyApp.pm
    use Catalyst qw(RunAfterRequest);

    #### In your controller
    sub my_action : Local {
        my ( $self, $c ) = @_;

        # do your normal processing...

        # add code that runs after response has been sent to client
        $c->run_after_request(    #
            sub { $self->do_something_slow(); },
            sub { $self->do_something_else_as_well(); }
        );

        # continue handling the request
    }


    #### Or in your Model:

    package MyApp::Model::Foo;

    use Moose;
    extends 'Catalyst::Model';
    with 'Catalyst::Model::Role::RunAfterRequest';

    sub some_method {
        my $self = shift;

        $self->run_after_request(
            sub { $self->do_something_slow(); },
            sub { $self->do_something_else_as_well(); }
        );
    }


=head1 DESCRIPTION

Sometimes you want to run something after you've sent the reponse back to the
client. For example you might want to send a tweet to Twitter, or do some
logging, or something that will take a long time and would delay the response.

This module provides a conveniant way to do that by simply calling
C<run_after_request> and adding a closure to it.

=head1 METHODS

=head2 run_after_request

    $c->run_after_request(
        sub { 
            # create preview of uploaded file and store to remote server
            # etc, etc
        },
        sub {
            # another closure...
        }
    );

Takes one or more anonymous subs and adds them to a list to be run after the
response has been sent back to the client.

=head1 AUTHOR

Matt S Trout (mst) <mst@shadowcat.co.uk>

Edmund von der Burg (evdb) <evdb@ecclestoad.co.uk>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
