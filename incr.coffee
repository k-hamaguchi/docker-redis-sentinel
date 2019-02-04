#!/usr/bin/env coffee
Redis = require 'ioredis'

sleep = (n) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, n

log = (msg) ->
  time = new Date().toJSON()
  console.log time, msg

main = ->
  redis = new Redis
    sentinels: [
      {
        host: '10.255.11.3'
        port: 26379
      }
    ]
    name: 'mymaster'

  redis.on 'connect', -> log 'connect'
  redis.on 'ready', -> log 'ready'
  redis.on 'error', -> log 'error'
  redis.on 'close', -> log 'close'
  redis.on 'reconnecting', -> log 'reconnecting'
  redis.on 'end', -> log 'end'
  
  while true
    log await redis.incr 'foo'
    await sleep 1000

do main
