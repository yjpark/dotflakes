set -gx https_proxy http://$argv[1]:$argv[2];
set -gx http_proxy http://$argv[1]:$argv[2];
set -gx all_proxy http://$argv[1]:$argv[2];
set -gx NIX_CURL_FLAGS -x http://$argv[1]:$argv[2]
