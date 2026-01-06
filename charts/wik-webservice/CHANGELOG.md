
## [wik-webservice-v0.5.0](https://github.com/wikodit/charts/compare/wik-webservice-v0.4.0...wik-webservice-v0.5.0) - 2026-01-06

### Bug Fixes

* use preferred affinity instead of required for CI testing
* correct probe ports in full-values.yaml for nginx-unprivileged
* add /tmp emptyDir volume for nginx CI testing
* use configurable port in ingress and update CI values
* use nginx-unprivileged image for CI testing
* correct storage configuration in volumes
* remove deprecated requirements.yaml file
* change ServiceAccount defaults for better security
* rename image pull secret from -docker to -registry

### CI/CD

* fix release action
* fix tests

### Code Refactoring

* rename docker-secret to registry-secret

### Documentation

* auto-generate chart documentation
* add image security best practices
* document security and resource defaults
* auto-generate chart documentation
* **wik-webservice:** improve NOTES.txt with dynamic feature sections

### Features

* add explicit host protection settings
* add Pod Security Standards support
* add runtimeClassName support
* add ephemeral storage limits by default
* add enableServiceLinks configuration
* add seccompProfile RuntimeDefault by default
* add startupProbe support
* add HorizontalPodAutoscaler support
* add ServiceMonitor support for Prometheus
* add TopologySpreadConstraints support
* add NetworkPolicy support
* add PodDisruptionBudget support
* add ServiceAccount configuration
* add default resource requests and limits
* add secure PodSecurityContext defaults
* add secure containerSecurityContext defaults
* add release badges to chart README templates


## wik-webservice-v0.4.0 - 2025-12-31

### Bug Fixes

* resolve Helm chart linting errors
* **wik-webservice:** v0.3.0
* **wik-webservice:** v0.2.1

### CI/CD

* linting & testing

### Documentation

* auto-generate chart documentation

### Features

* standardize all charts to v2 and add documentation templates
* **wik-webservice:** v0.4.0
* **wik-webservice:** v0.3.2
* **wik-webservice:** v0.3.1
* **wik-webservice:** v0.2.2
* **wik-webservice:** v0.2.0
* **wik-webservice:** v0.1.0
* **wik-webservice:** v0.0.5

