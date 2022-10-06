# create JKS storage with multiple keys and certs
Tested on: MacOS 12.4, Ubuntu 20.04\
Assuming you have:
  - `client.cert.pem` and `client.key.pem` - client certificate and key
  - `server.cert.pem` and `server.key.pem` - server certificate and key
  - trusted_certs - directory with trusted certificates
  - everything in [pem format](https://www.ssl.com/guide/pem-der-crt-and-cer-x-509-encodings-and-conversions/), keys are decrypted

    ```
    CERTS/
    ├── client.cert.pem
    ├── client.key.pem
    ├── server.cert.pem
    ├── server.key.pem
    └── trusted_certs
        ├── trusted_cert_1.cert.pem
        ├── trusted_cert_2.cert.pem
        ...
    ```

Use [getjks.bash](./getjks.bash) script to put everything in a single jks store

1. Ensure java version of script execution machine and jks storage destination matches to avoid [jks compatibility issue](https://community.oracle.com/tech/developers/discussion/4109117/getting-keystore-issues-after-jre-update-from-1-8-0-131-to-1-8-0-151-version) (somewhere between 1.8.0_131 and 1.8.0_151 things changed)

1. Ensure `keytool` is in place
1. Put [getjks.bash](./getjks.bash) alongside with client.cert.pem and server.cert.pem and run it

    ```
    ./getjks.bash 
    Please provide jks password: 
    [2022-10-06 07:26:32+0000] Removing existing keystore.jks
    [2022-10-06 07:26:32+0000] Creating p12 files
    [2022-10-06 07:26:32+0000] Adding client.cert.pem to jks with alias myclientcn
    Importing keystore client.p12 to keystore.jks...
    [2022-10-06 07:26:32+0000] Adding server.cert.pem to jks with alias my_server_cn
    Importing keystore server.p12 to keystore.jks...
    [2022-10-06 07:26:33+0000] Importing trusted certificates to keystore.jks
    [2022-10-06 07:26:33+0000] Adding trusted_certs/trusted_cert_1.cert.pem with alias trusted_cert_1
    Certificate was added to keystore
    [2022-10-06 07:26:33+0000] Adding trusted_certs/trusted_cert_2.cert.pem with alias trusted_cert_2
    Certificate was added to keystore
    ...
    ```