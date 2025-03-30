crt_path = '/secrets/tls-cert/tls.crt'
key_path = '/secrets/tls-cert/tls.key'

newServer(
   {
      address = '127.0.0.1:10053',
      maxInFlight = 1000,
   }
)

addTLSLocal(
   '0.0.0.0:10853', crt_path, key_path,
   {
      maxInFlight = 1000,
      minTLSVersion = 'tls1.3',
   }
)


addDOQLocal(
   '0.0.0.0:10853', crt_path, key_path,
   {
      maxInFlight = 1000,
   }
)

webserver(
   '0.0.0.0:9823'
)
setWebserverConfig(
   {
      acl = "127.0.0.1, 10.33.128.0/17",
      statsRequireAuthentication = false,
   }
)
