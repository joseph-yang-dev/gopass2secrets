# Overview
[GOPASS](https://www.gopass.pw/) is an opensource secret management tool, good fit for a team sharing secrets when combine with github as storage backend. There is a [GUI](https://github.com/codecentric/gopass-ui) of GOPASS to let user view/copy/update secrets. 

[Kubernates secrets](https://kubernetes.io/docs/concepts/configuration/secret/) is the cluster object a small amount of sensitive data such as a password, a token, or a key, being widely used by the application running in the cluster. 

This application is providing a synchronization steps to keep the GOPASS entries and sepecific kubernetes secrets the same.

# Prepare GOPASS
Using CentOS as an example:
1. install gpg and dependent softwares
```
dnf -y install gpg pinentry
export GPG_TTY=$(tty)
```

2. Generate gpg key
```
gpg --batch --passphrase 'password' --quick-gen-key myuser default default
```

3. Install GOPASS
```
cd /tmp
curl -s -L https://github.com/gopasspw/gopass/releases/download/v1.13.0/gopass-1.13.0-linux-amd64.tar.gz | tar xfvz -
mv gopass /bin

```

4. Setup GOPASS
```
gopass --yes setup --name myuser --email myuser@gmail.com
gopass update
```

After steps above, you will have a default GOPASS store in place to store your secrets. 

# Save existing kubernetes secrets into a GOPASS store
There are 3 steps to save your kubernetes to GOPASS:
1. Login to Kubernetes;
2. Create configmap to specify what secrets to be preserved;
3. Store secrets to GOPASS store

Before running this script, you need to logon to kubernetes, typically in OCP is "oc login". 

**SECRET_PATH** is the only critical parameter to specify where the secrets to be stored in GOPASS. In the Kubernetes cluster, we are using a configMap named **gopass-secrets** to store SECRET_PATH and the names of the secrets to be stored. 

After logging to Kubernetes, this steps can run as following to create the configMap:
```
export SECRET_PATH=
./setupConfigMap.sh
```

The script saveSecrets2gopass.sh can be used to preserve secrets to local GOPASS store. The only parameter is needed to perform this script is **SECRET_PATH**. By default its value is read from the configMap, of course you can specify the value in an enviroment variable to overwrite that from the configMap. To run that is straightforward as following:
```
export SECRET_PATH=
./saveSecrets2gopass.sh
```

# Update kubernetes screts from GOPASS
**gopass2secrets.sh** is the script to copy GOPASS secrets back to Kubernetes. If the secrets does not exist, this script also create that secret automatically; otherwise existing secret value will be overwritten. 

