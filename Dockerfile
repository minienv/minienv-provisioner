FROM docker:dind

RUN apk add --no-cache bash

COPY minienv-provisioner-entrypoint.sh /

ENTRYPOINT ["/minienv-provisioner-entrypoint.sh"]
