#!/usr/bin/env perl
use Mojo::Base -strict, -signatures, -async_await;
use YAML::XS;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);
use Mojo::URL;
use Mojo::Util qw(dumper);
use Mojo::Log;
use Text::Table;
use Time::Piece;
use Term::ExtendedColor ':attributes';

my $log = Mojo::Log->new->level( $ENV{MOJO_LOG_LEVEL} );
my $ua  = Mojo::UserAgent->new;
my @columns;
push @columns,
    bold($_)
    for (
    "NAMESPACE", "NAME",      "PHASE",     "START-TIME", "NODE",
    "IP",        "|",         "NAME",      "READY",      "RESTARTS",
    "CPU-REQ",   "CPU-LIMIT", "CPU-USAGE", "MEM-REQ",    "MEM-LIMIT",
    "MEM-USAGE", "MEM%"
    );
my $tb = Text::Table->new(@columns);

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
my ( $pods_info_ref, $pods_metrics_ref );
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
    $pods_info_ref    = $results[0]->[0]->result->json;
    $pods_metrics_ref = $results[1]->[0]->result->json;
    return;
}

get_pods_details_p($ua)->wait;

###############################################################################
###############################################################################
###############################################################################

sub utc_to_local ($utc_ts) {
    my $utc_tp   = Time::Piece->strptime( $utc_ts, '%Y-%m-%dT%H:%M:%SZ' );
    my $local_tp = localtime( $utc_tp->epoch );
    return $local_tp->strftime('%Y-%m-%d %I:%M:%S %p');
}

for my $pod_info_ref ( @{ $pods_info_ref->{items} } ) {
    my @tb_pod_row = (
        $pod_info_ref->{metadata}{namespace},
        $pod_info_ref->{metadata}{name},
        $pod_info_ref->{status}{phase},
        utc_to_local( $pod_info_ref->{status}{startTime} ),
        $pod_info_ref->{spec}{nodeName},
        $pod_info_ref->{status}{podIP},
    );
    my @empty_tb_pod_row = ( "", "", "", "", "", "" );
    my $tb_pod_row_added_already;

    my $pod_metrics_ref = (
        grep {
            $_->{metadata}{namespace} eq $pod_info_ref->{metadata}{namespace}
                and $_->{metadata}{name} eq $pod_info_ref->{metadata}{name}
        } @{ $pods_metrics_ref->{items} }
    )[0];

    for my $container_ref ( @{ $pod_info_ref->{spec}{containers} } ) {
        my $container_status_ref
            = ( grep { $_->{name} eq $container_ref->{name} }
                @{ $pod_info_ref->{status}{containerStatuses} } )[0];
        my $container_metrics_ref
            = ( grep { $_->{name} eq $container_ref->{name} }
                @{ $pod_metrics_ref->{containers} } )[0];

        $container_status_ref->{ready}
            = $container_status_ref->{ready}
            ? fg( "springgreen3", "✔" )
            : fg( "red2",         "X" );

        my @tb_container_row = (
            "|",
            $container_ref->{name},
            $container_status_ref->{ready},
            $container_status_ref->{restartCount},
            $container_ref->{resources}{requests}{cpu},
            $container_ref->{resources}{requests}{memory},
            $container_metrics_ref->{usage}{cpu},
            $container_ref->{resources}{limits}{cpu},
            $container_ref->{resources}{limits}{memory},
            $container_metrics_ref->{usage}{memory},
            "",
        );

        $tb->load(
            [   ( $tb_pod_row_added_already ? @empty_tb_pod_row : @tb_pod_row ),
                @tb_container_row
            ]
        );
        $tb_pod_row_added_already = 1;
    }
}

###############################################################################
###############################################################################
###############################################################################
binmode( STDOUT, "encoding(UTF-8)" );
print $tb;
