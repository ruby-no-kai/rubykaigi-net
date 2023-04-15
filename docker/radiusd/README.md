```
docker build -t rkrad . && docker run --rm --name rkrad --net=host -v $(pwd)/dummycert:/secrets/tls-cert:ro rkrad
docker kill rkrad
```

```
eapol_test -c ./eapol_test.conf -s testing123 -a 127.0.0.1
eapol_test -c ./eapol_fail.conf -s testing123 -a 127.0.0.1
```
