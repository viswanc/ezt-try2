# Manual

  A high-level intro on hoe to introduce an envoy-sidecar to an existing service.

## Notes

* This example revolves around a service, named service1 within this repo.

* This document is to give a overview on the current (basic) implementation, the final implementation could (and probably would) deviate from the steps to be told.

## Tips

  Take a look at the relevant deployment files (of service1). The comments in there talk in detail about the needed changes discussed here.

## Architecture

* Envoy is deployed as a separate container alongside the container of the service (as a sidecar).

* Requests in and out of the service are sent to Envoy (the sidecar proxy), which in turn routes those to the targets, as mentioned in envoy's configuration.

## Steps

### Code changes

  Services should propagate the following headers for request tracing across services to work properly.

#### Headers to propagate

* X-Request-Id
* X-B3-TraceId
* X-B3-SpanId
* X-B3-ParentSpanId
* X-B3-Sampled
* X-B3-Flags

  Look at the source of the **HTTP service (src/http/service.py)** for an example. Further info on tracing could be found [here](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/tracing.html).

### Deployment

* Add the envoy-sidecar container (from this repo) to the target deployment.

* Write a ConfigMap with envoy's configuration *(look at **service1/envoy-config.yaml**)*.

* Mount a volume to feed Envoy with the written ConfigMap.

### Configuring Envoy

* Configure Envoy to listen on the needed (one or more) addresses, at static_resources.listeners.address.

* For every listener write a filter_chain, with one or more filters.

* Change the tracing and routing configuration for every filter as needed.

* Define the clusters used by the filters.

* Apart from the filters, configure the tracing end-points (for Zipkin in this case) through the key, tracing.

Look at **service1/envoy-config.yaml** for an example.

For further info check envoy's documentation [here](https://www.envoyproxy.io/docs/envoy/v1.6.0/).
