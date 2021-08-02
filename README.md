# project-namespace

The `project-namespace` terraform module sets up a namespace in a kubernetes cluster with all of the things that are common across my projects. This allows me to very easily kick off new projects with optimal defaults.

Currently, it'll do the following:

- Create namespace
- Create a `deployer` service account
- Create a role binding for the `deployer` account with the `deployer` cluster role (this is shared across namespaces since these permissions are currently always the same)


## To do

- Add a docker pull secret to pull from `ghcr.io`
- Add a default `NetworkPolicy` that blocks all ingress + egress.
