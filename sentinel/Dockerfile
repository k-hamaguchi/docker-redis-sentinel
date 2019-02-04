FROM redis:alpine

COPY ./etc/sentinel.conf /etc/

EXPOSE 26379
CMD ["redis-sentinel", "/etc/sentinel.conf"]
