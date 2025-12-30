CHANGELOG
=========

v0.4.0
------
* feat: add metrics configuration with Prometheus annotations on Service
* feat: add service.port configuration (no longer hardcoded to 80)
* feat: add service.annotations support
* feat: add ingress.className support (modern ingressClassName spec)
* feat: add ingress.tlsAcme configuration
* feat: add terminationGracePeriodSeconds support
* feat: add Kubernetes version check for Ingress apiVersion (v1, v1beta1, extensions)
* fix: typo containerSsecurityContext in deployment template
* fix: duplicate release label in pod template
* docs: complete README with configuration tables and examples
* docs: add comprehensive examples in values.yaml

v0.3.2
------
* feat: add affinity

v0.3.1
------
* fix: wrong key in deployment for containerSecurityContext

v0.3.0
------
* feat: migrate securityContext to containerSecurityContext
* feat: add securityContext (not the container one)

v0.2.2
------
* feat: allow overriding command and entrypoint

v0.2.1
------
* fix: additionalContainers and initContainers optional env not respected
* fix: wrong condition livenessProbe instead of readinessProbe

v0.2.0
------
* add `webservice.ingress.enabled` and `webservice.service.enabled`