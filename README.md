# Test Redis Sentinel

## Replication

[Replication](https://redis.io/topics/replication)

Run one master(redis-master) and two slaves(redis-slave-1, redis-slave-2).

```bash
docker-compose up -d
```

Connect from master.

```bash
$ docker-compose exec redis-master redis-cli info replication | grep ^role
role:master
$ docker-compose exec redis-slave-1 redis-cli --raw info replication | grep ^role
role:slave
$ docker-compose exec redis-slave-2 redis-cli --raw info replication | grep ^role
role:slave
$ docker-compose exec redis-master redis-cli --raw set foo 1
OK
$ docker-compose exec redis-slave-1 redis-cli --raw get foo
1
$ docker-compose exec redis-slave-2 redis-cli --raw get foo
1
$ docker-compose exec redis-master redis-cli --raw incr foo
2
$ docker-compose exec redis-slave-1 redis-cli --raw get foo
2
$ docker-compose exec redis-slave-2 redis-cli --raw get foo
2
```

Connect from another container.

```bash
docker run -it --rm --network sentinel_default redis:alpine redis-cli -h redis-master
docker run -it --rm --network sentinel_default redis:alpine redis-cli -h redis-slave-1
docker run -it --rm --network sentinel_default redis:alpine redis-cli -h redis-slave-2
```
