# 根据他人prometheus的配置修改后的，作者的地址因长时间没有维护，在当下k8s版本有很多问题，这里调整的是manifests 目录下的配置


## Kubernetes Setup for Prometheus and Grafana

## Quick start

To quickly start all the things just do this:
```bash
kubectl apply \
  --filename https://raw.githubusercontent.com/giantswarm/kubernetes-prometheus/master/manifests-all.yaml
```

This will create the namespace `monitoring` and bring up all components in there.

To shut down all components again you can just delete that namespace:
```bash
kubectl delete namespace monitoring
```

## Default Dashboards

If you want to re-import the default dashboards from this setup run this job:
```bash
kubectl apply --filename ./manifests/grafana/grafana-import-dashboards-job.yaml
```

In case the job already exists from an earlier run, delete it before:
```bash
kubectl --namespace monitoring delete job grafana-import-dashboards
```


## More Dashboards

See grafana.net for some example [dashboards](https://grafana.net/dashboards) and [plugins](https://grafana.net/plugins).

- Configure [Prometheus](https://grafana.net/plugins/prometheus) data source for Grafana.<br/>
`Grafana UI / Data Sources / Add data source`
  - `Name`: `prometheus`
  - `Type`: `Prometheus`
  - `Url`: `http://prometheus:9090`
  - `Add`

- Import [Prometheus Stats](https://grafana.net/dashboards/2):<br/>
  `Grafana UI / Dashboards / Import`
  - `Grafana.net Dashboard`: `https://grafana.net/dashboards/2`
  - `Load`
  - `Prometheus`: `prometheus`
  - `Save & Open`

- Import [Kubernetes cluster monitoring](https://grafana.net/dashboards/162):<br/>
  `Grafana UI / Dashboards / Import`
  - `Grafana.net Dashboard`: `https://grafana.net/dashboards/162`
  - `Load`
  - `Prometheus`: `prometheus`
  - `Save & Open`

## Credit

Alertmanager configs and integration in this repository was heavily inspired by the implementation in [kayrus/prometheus-kubernetes](https://github.com/kayrus/prometheus-kubernetes).
