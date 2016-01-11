FROM williamyeh/ansible:alpine3

ADD . /app/
ENV ANSIBLE_HOST_KEY_CHECKING False
ENTRYPOINT ["/app/entrypoint.sh"]
