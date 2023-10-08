HELM_RELEASE_NAME = metrics-server
HELM_NAMESPACE = default

install:
	@echo "[info] install kind cluster"
	@kind create cluster --config kind-config.yaml

uninstall:
	@echo "[info] delete kind cluster"
	@kind delete cluster --name metrics-server-practice

install-metrics-server:
	@echo "[info] install latest metrics sevrer"
	@helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
	@helm upgrade --install -n ${HELM_NAMESPACE} -f helm-values.yaml ${HELM_RELEASE_NAME} metrics-server/metrics-server

uninstall-metrics-server:
	@echo "[info] uninstall metrics server"
	@helm uninstall -n ${HELM_NAMESPACE} ${HELM_RELEASE_NAME}
