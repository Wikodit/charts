CHANGELOG
=========

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