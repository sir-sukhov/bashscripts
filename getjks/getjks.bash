#!/bin/bash
#
# MIT License
#
# Copyright (c) 2020 sir-sukhov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
function log {
  echo "$(date +"[%Y-%m-%d %H:%M:%S%z]") $@"
}

function getAlias {
  file=$1
  openssl x509 -noout -subject -in $file | grep -oEe 'CN[ ]*=[ ]*[^,]+' | cut -d '=' -f 2 | xargs | cut -d '.' -f 1 | tr [:upper:] [:lower:] | tr ' ' '_' | tr '-' '_'
}

echo -n "Please provide jks password: " && read -s PSSWRD && echo

[ -f keystore.jks ] && log "Removing existing keystore.jks" && rm -rf keystore.jks

log "Creating p12 files"
for f in client server
do
   a=$(getAlias ${f}.cert.pem)
   log "Adding ${f}.cert.pem to jks with alias $a"
   openssl pkcs12 -export -in ${f}.cert.pem -inkey ${f}.key.pem \
      -out ${f}.p12 -name $a -password pass:$PSSWRD 
   keytool -importkeystore -deststorepass $PSSWRD -destkeystore keystore.jks \
      -srckeystore ${f}.p12 -srcstoretype PKCS12 -srcstorepass $PSSWRD -alias $a
   rm -rf ${f}.p12
done

log "Importing trusted certificates to keystore.jks"
for cert in $(ls -1 trusted_certs)
do
   f=trusted_certs/$cert
   a=$(getAlias $f)
   log "Adding $f with alias $a"
   keytool -importcert -noprompt -file $f \
     -keystore keystore.jks -alias $a -storepass $PSSWRD
done

log "Listing result"
keytool -list -keystore keystore.jks -storepass $PSSWRD
