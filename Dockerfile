FROM amazon/aws-sam-cli-build-image-go1.x:latest

RUN mkdir -p /github
RUN /usr/sbin/useradd -m -d /github/home -u 1001 github

ADD entrypoint.sh cleanup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/cleanup.sh

USER github
WORKDIR /github/home

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]