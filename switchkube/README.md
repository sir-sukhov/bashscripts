# Switch to another OpenShift cluster

May work with kubernetes, though not tested (yet). \
Problem description: by default, you can connect to 1 cluster at a time. \
To work with different clusters from different terminal tabs for example, \
one might want to use [KUBECONFIG environment variable](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) \
\
This script allows quickly switch between OpenShift clusters without re-login and work with different clusters from different terminal tabs. \

Use it with `source` command to correctly set up `KUBECONFIG` environment variable:

```
source ./switchkube.bash
```

For convenience, add alias to .bash_profile

```
alias switchkube='source /Users/user/bashscripts/switchkube/switchkube.bash'
```
