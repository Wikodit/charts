wik-webservice
==============

## Introduction

This charts aims to simplify the deployment of a webservice on a redis cluster

It setups :

* ConfigMap with environment variables
* Secret with docker pull secret
* Deployment with an image
* Service and Ingress with an host

## Configuration

cf. possible configuration in the `values.yaml`