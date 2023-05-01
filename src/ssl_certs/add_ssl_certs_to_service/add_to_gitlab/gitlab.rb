## GitLab configuration settings
external_url 'https://localhost'
letsencrypt['enable'] = false
nginx['enable'] = true
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/localhost/public_key.pem"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/localhost/private_key.pem"
nginx['listen_port'] = 443
nginx['listen_https'] = true
