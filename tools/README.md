# tadamo/tools

Small image with several tools installed for testing/debugging. (See `Dockerfile`)

## build

```shell
docker buildx build --push --platform linux/arm/v7,linux/arm64/v8,linux/amd64 -t tadamo/tools:latest .
```

## Usage Examples

### Docker

```shell
# start simple http server
docker run -it --rm -p 8000:8000 tadamo/tools:latest simple-http-server
server {
    listen 8000 default_server reuseport;
    location / {
        add_header X-Simple-Server '👍';
        return 200 '
            host                                 = $host
            hostname                             = $hostname
            http_name                            = $http_name
            https                                = $https
            http_user_agent                      = $http_user_agent
            query_string                         = $query_string
            remote_addr                          = $remote_addr
            remote_port                          = $remote_port
            remote_user                          = $remote_user
            request                              = $request
            request_body                         = $request_body
            request_completion                   = $request_completion
            request_header_content_length        = $content_length
            request_header_content_type          = $content_type
            request_header_accept                = $http_accept
            request_header_host                  = $http_host
            request_method                       = $request_method
            request_time                         = $request_time
            request_uri                          = $request_uri
            request_scheme                       = $scheme
            response_header_server               = $sent_http_server
            response_header_date                 = $sent_http_date
            response_header_content_type         = $sent_http_content_type
            response_header_content_length       = $sent_http_content_length
            response_header_connection           = $sent_http_connection
            response_header_x_simple_server      = $sent_http_x_simple_server
            server_addr                          = $server_addr
            server_name                          = $server_name
            server_port                          = $server_port
            server_protocol                      = $server_protocol
            status                               = $status
            time_local                           = $time_local
            time_iso8601                         = $time_iso8601
            uri                                  = $uri
        ';
    }
    location /ok {
        return 200 'OK';
    }
}
```

### OpenShift

```
oc run tools \
  --image=tadamo/tools:latest
  --image-pull-policy='Always'
  --limits='cpu=20m,memory=20Mi'
  -- sleep "1000000"
```

OR

```
oc apply -f https://raw.githubusercontent.com/tadamo/dockerfiles/master/tools/tools.yaml
oc apply -f https://raw.githubusercontent.com/tadamo/dockerfiles/master/tools/tools-simple-http-server.yaml
```
