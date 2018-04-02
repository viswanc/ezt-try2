Envoy + Zipkin Tracing - Try 2
==============================

  Trial2 of the spike for implementing Zipkin tracing on a Kubernetes cluster.

Setup
-----
Run the following commands.

```
$ sh setup.sh # Setup the project.

$ sh dep/configure.sh apply # Deploy the artifacts to GKE.
```

Issues
------

* As of now, the primary blocker is that the grpc-service couldn't be accessed through Envoy. But, it works with port-forwarding and load-balancing.

ToDo
----

* Use files, instead of strings to configure Envoy. The issue is, such a way is unknown.

* Try Jaeger tracing. Envoy's base repo has a working example.

Notes
-----

* The base is a conversion of docker-compose files from envoy's zipkin example. The conversion was done with the help of *kompose*.

Log
---

* 180328

  * 2258  Initiated the repo with a simple working implementation of the http services.
  * 2322  Ran a simple HTTP service.
  * 2338  Ran the HTTP service using config.

* 180328

  * 0030  Decoupled the envoy-sidecar, as a container.
  * 0035  Exposed the HTTP service through front-envoy and verified Zipkin tracing for the same.
  * 0101  Added service2.

* 180302

  * 1930  Reorganized for a demo.
  * 2011  Changed a some labels.
  * 2032  Imported the grpc-wrapper into the repo.
  * 2104  Made the go services to accept a command line argument for the port to listen.
  * 2118  Added a script to ensure that the gRPC service is accessible through a load-balancer.
