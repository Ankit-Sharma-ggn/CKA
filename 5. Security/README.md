<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.svg"
       alt="Kubernetes Logo" width="140">
</p>

<h1 align="center">Security</h1>

## Authentication

- kubernetes rely on third party app, certificates or ldap solutions to manage user access.

- kube-apiserver authenticate the requests.

- way to manager user access
    1. **static password files**: csv file with password, user-name and userid's, and then update the kube-apiserver settings to add option `--basic-auth-file=user-details.csv`

    `curl -v -k https://master-node-ip:6443/api/v1/pods -u "user1:password123"`
    
    2. **Static Token file**: simillar to password file, we can have a static token file for authentication, `--token-auth-file=user-token-details.csv`

    `curl -v -k https://master-node-ip:6443/api/v1/pods -header "Authorization: Bearer KpjsedsddsdfHwe@sexcfded"`

    3. Certificates 

      ## link -> ![Certificates](Certificate.md)
                            
    4. Identity Services, i.e ldap

