# Test Redis Sentinel

## Replication

[Replication](https://redis.io/topics/replication)

Run one master(redis-master) and two slaves(redis-slave_1, redis-slave_2).

```bash
docker-compose up --scale redis-slave=2
```

Modifications on the master are replicated to slaves.

```bash
$ docker-compose exec redis-master redis-cli info replication | grep ^role
role:master
$ docker-compose exec --index=1 redis-slave redis-cli info replication | grep ^role
role:slave
$ docker-compose exec --index=2 redis-slave redis-cli info replication | grep ^role
role:slave
$ docker-compose exec redis-master redis-cli --raw set foo 1
OK
$ docker-compose exec --index=1 redis-slave redis-cli --raw get foo
1
$ docker-compose exec --index=2 redis-slave redis-cli --raw get foo
1
$ docker-compose exec redis-master redis-cli --raw incr foo
2
$ docker-compose exec --index=1 redis-slave redis-cli --raw get foo
2
$ docker-compose exec --index=2 redis-slave redis-cli --raw get foo
2
$ docker-compose exec --index=1 redis-slave redis-cli --raw incr foo
READONLY You can't write against a read only slave.
$ docker-compose exec --index=2 redis-slave redis-cli --raw incr foo
READONLY You can't write against a read only slave.
```

## Sentinel

[Redis Sentinel Documentation](https://redis.io/topics/sentinel)

### Start servers

Start one master, two slaves and three sentinels.

```bash
docker-compose up --scale redis-sentinel=3 --scale redis-slave=2
```

### Connect to sentinel

```bash
docker-compose exec --index=1 redis-sentinel redis-cli -p 26379
```

### Testing the failover

#### Failover

```bash
$ docker-compose exec redis-master redis-cli ROLE
1) "master"
2) (integer) 3769891
3) 1) 1) "10.255.11.6"
      2) "6379"
      3) "3769891"
   2) 1) "10.255.11.5"
      2) "6379"
      3) "3769891"
$ docker-compose exec redis-master redis-cli DEBUG sleep 30
$ docker-compose exec redis-sentinel redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
1) "10.255.11.5"
2) "6379"
$ docker-compose exec redis-sentinel redis-cli -h 10.255.11.5 -p 6379 ROLE
1) "master"
2) (integer) 3738399
3) 1) 1) "10.255.11.6"
      2) "6379"
      3) "3738125"
   2) 1) "10.255.11.2"
      2) "6379"
      3) "3738125"
```

#### Failback

```bash
$ docker-compose exec --index 1 redis-slave redis-cli DEBUG sleep 30
$ docker-compose exec redis-sentinel redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
1) "10.255.11.2"
2) "6379"
$ docker-compose exec redis-sentinel redis-cli -h 10.255.11.2 -p 6379 ROLE
1) "master"
2) (integer) 3764095
3) 1) 1) "10.255.11.6"
      2) "6379"
      3) "3764095"
   2) 1) "10.255.11.5"
      2) "6379"
      3) "3764095"
```

### Reconnecting from the client

Start the client.

```bash
./incr.coffee
```

Stop the master to failover.

```bash
$ docker-compose stop redis-master
Stopping sentinel_redis-master_1 ... done
```
