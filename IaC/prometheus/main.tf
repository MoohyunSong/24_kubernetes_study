resource "helm_release" "kube-prometheus-stack" {
  namespace  = "kube-system"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  name       = "kube-prometheus-stack"

  set = [{
    name = "grafana.adminPassword"
    value = "password"
  },
  {
    name = "grafana.ingress.enabled"
    value = "true"
  },
  {
    name = "grafana.ingress.ingressClassName"
    value = "nginx"
  },
  {
    name = "grafana.ingress.path"
    value = "/monitor"
  },
  {
    name = "grafana.grafana\\.ini.server.root_url"
    value = "%(protocol)s://%(domain)s/monitor"
  },
  {
    name = "grafana.grafana\\.ini.server.serve_from_sub_path"
    value = "true"
  }]
}
