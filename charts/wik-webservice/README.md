wikodit webservice
==============

## Introduction

This charts aims to simplify the deployment of a webservice.

It setups :

* ConfigMap/Secret/SealedSecret with environment variables
* Secret/SealedSecret with docker pull secret
* Deployment with an image
* Service and Ingress with an host
* PVC...