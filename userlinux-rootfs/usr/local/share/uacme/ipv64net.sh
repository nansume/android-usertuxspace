#!/bin/sh
# -------------------------------------------------------
# File: /usr/local/share/uacme/ipv64net.sh 0755 root:root
# -------------------------------------------------------
# uacme hook for ipv64.net DNS-01 challenge
# Usage: uacme -v -c /etc/ssl/uacme -h /usr/local/share/uacme/ipv64net.sh issue $(domain-name)

#API_URL="https://ipv64.net/dnsapi"  # It wrong
API_URL="https://ipv64.net/api.php"
API_URL="https://ipv64.net/api"
API_KEY="$(head -n1 /etc/sysconfig/uacme/ipv64net/token)"  # your account API key/token from ipv64.net

METHOD=$1
TYPE=$2
IDENT=$3
TOKEN=$4
AUTH=$5

# Extract the prefix (first label) from the full record name
# e.g. _acme-challenge.example.com -> _acme-challenge
#get_prefix() { printf %s "${1}" | cut -d. -f1 ;}
get_prefix() { printf %s "${1%%.*}" ;}

case "${METHOD}" in
  "begin")
    case "${TYPE}" in
      dns-01)
        PREFIX=$(get_prefix "_acme-challenge.${IDENT}")
        curl -fsS -X POST "${API_URL}" \
          -H "Authorization: Bearer ${API_KEY}" \
          --data-urlencode "add_record=${IDENT}" \
          --data-urlencode "praefix=${PREFIX}" \
          --data-urlencode "type=TXT" \
          --data-urlencode "content=${AUTH}"
        # Wait for DNS propagation
        sleep 30
        exit $?
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  "done"|"failed")
    case "${TYPE}" in
      dns-01)
        PREFIX=$(get_prefix "_acme-challenge.${IDENT}")
        curl -fsS -X DELETE "${API_URL}" \
          -H "Authorization: Bearer ${API_KEY}" \
          --data-urlencode "del_record=${IDENT}" \
          --data-urlencode "praefix=${PREFIX}" \
          --data-urlencode "type=TXT" \
          --data-urlencode "content=${AUTH}"
        exit $?
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  *)
    echo "$0: invalid method" 1>&2
    exit 1
    ;;
esac
