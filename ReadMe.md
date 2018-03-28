Envoy + Zipkin Tracing -Try 2
=============================

  Trial2 of the spike for implementing Zipkin tracing on a Kubernetes cluster.

Notes
-----

* The base is a conversion of a docker-compose files from envoy's zipkin example. The conversion was done with the help of *kompose*.

Log
---

* 180328

  * 2258  Initiated the repo with a simple working implementation of the http services.
  * 2322  Ran a simple HTTP service.
  * 2338  Ran the HTTP service using config.

* 180328

  * 0030  Decoupled the envoy-sidecar, as a container.
  * 0035  Exposed the HTTP service through front-envoy and verified Zipkin tracing for the same.
