#!/bin/sh

# Wating for the file via `wait-for-file.sh` is enough.
# We don't need to use `jq` and wait for Certificates within it to be populated,
# as seen here: https://github.com/ldez/traefik-certs-dumper/blob/c11dd6630f87684ceb0bd102b1a0a0f5245d72ac/docs/docker-compose-traefik-v2.yml#L27-L38
#
# This is because:
# - traefik-certs-dumper does not choke when Certificates is null - it just dumps nothing
# - we use `--watch`, so we whenever Certificates changes to not null, it will be dumped again

/certs-dumper-bin/wait-for-file.sh /in/acme.json \
&& \
/usr/bin/traefik-certs-dumper file \
--version v2 \
--source /in/acme.json \
--dest /intermediate \
--watch \
--post-hook "/bin/sh /certs-dumper-bin/copy-certificates.sh /intermediate /staging /out" \
--domain-subdir 
