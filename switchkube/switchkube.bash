#!/bin/bash
#
# MIT License
#
# Copyright (c) 2022 sir-sukhov
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
config=$1
function log {
	echo "$(date +"[%Y-%m-%d %H:%M:%S%z]:") $@"
}
ERROR="false"
[ ! -z $config ] \
  && ! [[ $config =~ ^[a-zA-Z0-9\-]+$ ]] \
  && log "ERROR: config name must match regexp ^[a-zA-Z0-9\-]+$" \
  && ERROR="True"
if [ -z $config ] && [ -d ${HOME}/kubeconfigs ] && [[ $(ls -1 ${HOME}/kubeconfigs | wc -l | tr -d ' ') != 0 ]]
then
  configs=($(ls -1 ${HOME}/kubeconfigs | tr '\n' ' ' | tr -s ' '))
  i=1
  log "Listing existing configs"
  while [[ $i -le  ${#configs[@]} ]]
  do
    echo "$i. - ${configs[$(( i - 1 ))]}"
    (( i++ ))
  done
  log "Please provide config from above or the new name"
  echo -n "config number or new name: "
  read i
  if [[ $i =~ ^[0-9]+$ ]] && [[ $i -le ${#configs[@]} ]] && [[ $i -gt 0 ]]
  then
    config=${configs[$((i-1))]}
  elif [[ $i =~ ^[a-zA-Z0-9\-]+$ ]]
  then
    config=$i
  else
    log "ERROR: config name must match regexp ^[a-zA-Z0-9\-]+$"
    ERROR="True"
  fi
elif [ -z $config ]
then
  log "Please provide new config name"
  echo -n "config name: "
  read config
  mkdir -p ${HOME}/kubeconfigs
fi

if ! [[ $ERROR == "True" ]]
then
  [ ! -d ${HOME}/kubeconfigs/$config ] \
    && log "config $config does not exists" \
    && log "Creating directory ${HOME}/kubeconfigs/$config" \
    && mkdir -p "${HOME}/kubeconfigs/$config/.kube"

  log "Switching to config $config by creating these environment variables:"
  echo "#######################"
  echo "export PS1='\h:\W \u\$([ ! -z \${KUBECONFIG} ] && echo -n \"(\" && echo -n \$KUBECONFIG | cut -d'/' -f5 | tr -d \"\n\" && echo -n \")\")$ '"
  echo "export KUBECONFIG=\"${HOME}/kubeconfigs/$config/.kube/config\""
  echo "#######################"
  export PS1='\h:\W \u$([ ! -z ${KUBECONFIG} ] && echo -n "(" && echo -n $KUBECONFIG | cut -d'/' -f5 | tr -d "\n" && echo -n ")")$ '
  export KUBECONFIG="${HOME}/kubeconfigs/$config/.kube/config"
  log "Use this script to login new OpenShift cluster"
  echo "#######################"
  cat <<EOF
  echo -n "User: " && read MYUSR \\
              && echo -n "Password: " && read -s MYPWD && echo \\
              && echo -n "Server(like https://api.mycluster.mydomain.com:6443/): " && read MYSRV \\
              && oc login -u "\$MYUSR" -p "\$MYPWD" --server="\${MYSRV}" \\
              && unset MYPWD
EOF
  echo "#######################"
fi
