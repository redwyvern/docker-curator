FROM alpine:3.6

RUN apk --no-cache add coreutils python py-setuptools py-pip gcc libffi py-cffi python-dev libffi-dev py-openssl musl-dev linux-headers openssl-dev libssl1.0 && \
    pip install elasticsearch-curator==5.4.0 && \
    pip install boto3==1.4.8 && \
    pip install requests-aws4auth==0.9 && \
    pip install cryptography==2.1.3 && \
    apk del py-pip gcc python-dev libffi-dev musl-dev linux-headers openssl-dev && \
    sed -i '/import sys/a urllib3.contrib.pyopenssl.inject_into_urllib3()' /usr/bin/curator && \
    sed -i '/import sys/a import urllib3.contrib.pyopenssl' /usr/bin/curator && \
    sed -i '/import sys/a import urllib3' /usr/bin/curator

RUN mkdir -p /opt/curator

COPY curator.yml /opt/curator
COPY actions.yml /opt/curator

# Run the actions daily
RUN touch crontab.tmp \
    && echo '25 6 * * * /usr/bin/curator /opt/curator/actions.yml --config /opt/curator/curator.yml' > crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD /usr/bin/curator /opt/curator/actions.yml --config /opt/curator/curator.yml && /usr/sbin/crond -f
