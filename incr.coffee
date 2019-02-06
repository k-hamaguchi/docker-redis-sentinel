#!/usr/bin/env coffee
Redis = require 'ioredis'

sleep = (n) ->
  new Promise (resolve, reject) ->
    setTimeout resolve, n

log = (msg) ->
  time = new Date().toLocaleTimeString()
  console.log time, msg

mainLoop = (sentinels) ->
  # get the master from sentinels.
  log "SENTINELS: " + ("#{s.host}:#{s.port}" for s in sentinels).join ', '
  redis = new Redis
    sentinels: sentinels
    name: 'mymaster'

  # log all events.
  redis.on 'connect', -> log 'CONNECT'
  redis.on 'ready', -> log 'READY'
  redis.on 'error', -> log 'ERROR'
  redis.on 'close', -> log 'CLOSE'
  redis.on 'reconnecting', -> log 'RECONNECTING'
  redis.on 'end', -> log 'END'

  # increment key forever.
  while true
    log await redis.incr 'foo'
    await sleep 1000

main = (args) ->
  try
    # get port numbers from arguments.
    ports = args.map(Number).filter(Number.isInteger)
    # set the default if port numbers were not specified.
    ports = [26379, 26380, 26381] unless ports.length
    # Your can specify the host via environment variable.
    host = process.env.HOST or 'localhost'
    sentinels = ports.map (port) -> host: host, port: port
    await mainLoop sentinels
  catch err
    console.error err
    process.exit 1

main process.argv[2..]
