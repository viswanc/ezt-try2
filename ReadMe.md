# Envoy + Zipkin Tracing - Try 2

  Trial-2 of the spike for implementing Zipkin tracing on a Kubernetes cluster.

## Setup
Run the following commands.

```
$ sh setup.sh # Setup the project.

$ sh dep/setup/deploy.sh # Deploy the artifacts to GKE's current namespace. #Note: Disregard any errors on the first-run. In case of a failiure, just break and rerun the script.
```

## Demo

* Check the dir dep/demo for some demos.

## Issues

* *None, yet.*

## ToDo

* Fix statsd and prometheus.

* Install the needed packages and dependencies through setup.sh.

* Find a better way to propagate headers.

* Use files, instead of strings to configure Envoy. The issue is, such a way is unknown.

* Try Jaeger tracing. Envoy's base repo has a working example.

## Notes

* The base is a conversion of docker-compose files from envoy's zipkin example. The conversion was done with the help of *kompose*.

## Structure

* src - The source files for the services.

* dep - The deployment files.

  * services - Deployment scripts for the services.

  * gateways - The components that expose the services to the internet. They are kept separate from other components, as they take quite some time to acquire external IPs.

  * components - Components of the system other than gateways and services.

## Log

* 180328

  * 2258  Initiated the repo with a simple working implementation of the http services.
  * 2322  Ran a simple HTTP service.
  * 2338  Ran the HTTP service using config.

* 180329

  * 0030  Decoupled the envoy-sidecar, as a container.
  * 0035  Exposed the HTTP service through front-envoy and verified Zipkin tracing for the same.
  * 0101  Added service2.

* 180302

  * 1930  Reorganized for a demo.
  * 2011  Changed a some labels.
  * 2032  Imported the grpc-wrapper into the repo.
  * 2104  Made the go services to accept a command line argument for the port to listen.
  * 2118  Added a script to ensure that the gRPC service is accessible through a load-balancer.
  * 2130  Improved the demo script.

* 180303

  * 0610  Successfully made a gRPC call.
  * 0625  Successfully made gRPC calls through the load-balancer and the grpc-wrapper service.
  * 1145  Restructured the project for easier operations.
  * 1520  Started using docker as the container repo.
  * 1645  Minor fixes to the scripts.
  * 2350  Removed some unused config.

* 180304

  * 1216  Removed a few superseded files.
  * 1726  Added a manual.

* 180305

  * 1644  Rewrote the route **grpc-wrapper/dynamic/** to request a given URL.
  * 1835  Tested gRPC multiplexed load-balancing through Envoy. Kubernetes, by default doesn't offer this.

* 180406

  * 0600  Added a few utility scripts.
  * 0648  Wrote a demo for load-balancing multiplexed requests through envoy.
  * 0727  Refactored the client application.
  * 0838  Fixed the breakage in the propagation of tracing headers.
  * 1430  Minor fixes to the shell scripts.
  * 1654  Basic setup for the prober done.
  * 2000  Successfully reset the pods.

* 180408

  * 0202  Renamed Prober to Probe.

* 180409

  * 1802  Verified that Envoy runs on Kubernetes v1.10.0.
  * 2014  Setup probe for a service (grpc-wrapper).

* 180410

  * 0114  Setup probe for an envoy sidecar.
  * 0142  Setup probe for another service, grpc-service.
  * 2028  Added a utils script, helpers.sh, with helper functions.
  * 2145  Probes reset successful.

* 180411

  * 0034  Made the gRPC services to log pod info, so to allow for easier tracing.
  * 0106  Implemented a front-envoy for the probes.
  * 0114  Added a demo for multi-pod load-balancing.
  * 0144  Improved probe setup.
  * 0324  Added multiplexed service calls to the grpc-wrapper.
  * 0954  Added zipkin tracing to the probes.

* 180412

  * 1544  Improved a few scripts.

* 180416

  * 2143  Added a helper script, kube.sh.

* 180417

  * 0007  Verified multi-pod load-balancing on GCE with 10 pods per service.

* 180420

  * 2152 Improved the utils script, getPods.sh.

* 180508

  * 1404  Added the structures for Prometheus and StatsD.
  * 1454  Bug fixed: Volumes couldn't be mounted to */etc* on minikube. Now they're mounted to */app*, instead.

* 180509

  * 2155  Renamed the service, *http* to *py_http*.
