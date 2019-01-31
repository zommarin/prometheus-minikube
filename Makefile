#
#
#

KUBECONFIG = $(shell echo ~/.kube/minikube.yaml)
export KUBECONFIG

.PHONY: restart-minicube
restart-minicube: kill-minikube
	 minikube start \
	 	--kubernetes-version=v1.13.2 \
	 	--memory=4096 \
	 	--bootstrapper=kubeadm \
	 	--extra-config=kubelet.authentication-token-webhook=true \
	 	--extra-config=kubelet.authorization-mode=Webhook \
	 	--extra-config=scheduler.address=0.0.0.0 \
	 	--extra-config=controller-manager.address=0.0.0.0
	minikube addons enable ingress

.PHONY: kill-minikube
kill-minikube:
	 -minikube stop
	 -minikube delete

.PHONY: install-prometheus-package
install-prometheus-package:
	 -kubectl apply -f prometheus-operator/contrib/kube-prometheus/manifests/
	 until kubectl get customresourcedefinitions servicemonitors.monitoring.coreos.com ; do date; sleep 1; echo ""; done
	 until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
	 kubectl apply -f prometheus-operator/contrib/kube-prometheus/manifests/
	 kubectl apply -f prometheus-ingress.yaml

.PHONY: setup-etc-hosts
setup-etc-hosts:
	sudo hostess add grafana.minikube $$(minikube ip)
	sudo hostess add prometheus.minikube $$(minikube ip)
	sudo hostess add alert-manager.minikube $$(minikube ip)

open-grafana:
	open http://grafana.minikube

open-prometheus:
	open http://prometheus.minikube

open-alert-manager:
	open http://alert-manager.minikube

