#!/usr/bin/env perl
use Mojo::Base -strict, -signatures, -async_await;
use YAML::XS;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);
use Mojo::URL;
use Mojo::Util qw(dumper);
use Mojo::Log;

my $log = Mojo::Log->new;
my $ua  = Mojo::UserAgent->new;

###############################################################################
###############################################################################
###############################################################################
my $kubeconfig
    = YAML::XS::Load( Mojo::File->new( $ENV{KUBECONFIG} )->slurp );
my ( $k8s_current_namespace, $k8s_current_server, $k8s_current_user )
    = split '/', $kubeconfig->{"current-context"};
$log->debug("k8s_current_namespace: $k8s_current_namespace");
$log->debug("k8s_current_server: $k8s_current_server");
$log->debug("k8s_current_user: $k8s_current_user");

my $k8s_current_api_server
    = ( grep { $_->{name} eq $k8s_current_server }
        @{ $kubeconfig->{clusters} } )[0]->{cluster}{server};
$log->debug("k8s_current_api_server: $k8s_current_api_server");

my $k8s_current_user_api_token
    = ( grep { $_->{name} eq "$k8s_current_user/$k8s_current_server" }
        @{ $kubeconfig->{users} } )[0]->{user}{token};
$log->debug("k8s_current_user_api_token: $k8s_current_user_api_token");

my $k8s_pods_api_url
    = Mojo::URL->new(
    "$k8s_current_api_server/api/v1/namespaces/$k8s_current_namespace/pods");
$log->debug( "k8s_pods_api_url: " . $k8s_pods_api_url->to_string );

my $k8s_metrics_pods_api_url
    = Mojo::URL->new(
    "$k8s_current_api_server/apis/metrics.k8s.io/v1beta1/namespaces/$k8s_current_namespace/pods"
    );
$log->debug(
    "k8s_metrics_pods_api_url: " . $k8s_metrics_pods_api_url->to_string );

my $k8s_api_server_request_headers
    = Mojo::Headers->new->authorization("Bearer $k8s_current_user_api_token")
    ->accept("application/json");
$log->debug( "k8s_api_server_request_headers, $_: "
        . $k8s_api_server_request_headers->to_hash->{$_} )
    for keys %{ $k8s_api_server_request_headers->to_hash };

###############################################################################
###############################################################################
###############################################################################

# Search kubapi non-blocking for multiple terms concurrently
my ( $pod_info_ref, $pod_metrics_ref );
async sub get_pods_details_p ($ua) {
    my @results = await Mojo::Promise->all(
        $ua->get_p(
            $k8s_pods_api_url => $k8s_api_server_request_headers->to_hash
        ),
        $ua->get_p(
            $k8s_metrics_pods_api_url =>
                $k8s_api_server_request_headers->to_hash
        ),
    );
    $pod_info_ref    = $results[0]->[0]->result->json;
    $pod_metrics_ref = $results[1]->[0]->result->json;
    return;
}

get_pods_details_p($ua)->wait;

###############################################################################
###############################################################################
###############################################################################