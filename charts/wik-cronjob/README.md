wikodit cronjob
==============

## Introduction

This charts aims to simplify the deployment of a cronjob.

It setups :

* ConfigMap/Secret/SealedSecret with environment variables
* Secret/SealedSecret with docker pull secret
* PVC...