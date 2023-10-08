# 개요
* 쿠버네티스 metrics-server 학습

# 환경 구축
* kind 클러스터 생성

```bash
make install
```

# 실습
## 실습 시나리오
* metrics server 설치 전후를 비교

## metrics server가 없는 상황
* pod 메트릭 조회

```bash
$ kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"
Error from server (NotFound): the server could not find the requested resource
```

* API server pod log조회: resp=404

```bash
$ kubectl -n kube-system logs -f -l component=kube-apiserver | grep "/apis/metrics"
I1008 04:37:11.770951       1 httplog.go:132] "HTTP" verb="LIST" URI="/apis/metrics.k8s.io/v1beta1/pods" latency="556.708µs" userAgent="kubectl/v1.24.3 (darwin/arm64) kubernetes/aef86a9" audit-ID="f6579fa5-e42a-4dc7-93f6-30821140806a" srcIP="172.18.0.1:60528" apf_pl="exempt" apf_fs="exempt" apf_iseats=1 apf_fseats=0 apf_additionalLatency="0s" apf_execution_time="41.167µs" resp=404
```

* kubectl top 명령어 실행

```bash
# node 메트릭 조회
$ kubectl top node

# pod 메트릭 조회
$ kubectl top pod
```

## metrics server 설치
* helm으로 설치

```bash
make install-metrics-server
```

* metrics server pod 조회

```bash
$ kubectl -n default get pod
NAME                              READY   STATUS    RESTARTS   AGE
metrics-server-596d577f98-zmmfx   1/1     Running   0          7m52s
```

## metrics server가 있는 상황
* node 메트릭 조회

```bash
# node이름 조회
$ kubectl get node
metrics-server-practice-control-plane   Ready    control-plane   8m35s   v1.28.0
metrics-server-practice-worker          Ready    <none>          8m12s   v1.28.0
metrics-server-practice-worker2         Ready    <none>          8m15s   v1.28.0

# node 메트릭 조회
$ NODENAME="metrics-server-practice-worker"
$ kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes/${NODENAME}"
{
  "kind": "NodeMetrics",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {
    "name": "metrics-server-practice-worker",
    "creationTimestamp": "2023-10-08T03:55:30Z",
    "labels": {
      "beta.kubernetes.io/arch": "arm64",
      "beta.kubernetes.io/os": "linux",
      "kubernetes.io/arch": "arm64",
      "kubernetes.io/hostname": "metrics-server-practice-worker",
      "kubernetes.io/os": "linux"
    }
  },
  "timestamp": "2023-10-08T03:55:20Z",
  "window": "10.019s",
  # 메트릭
  "usage": {
    "cpu": "33941012n",
    "memory": "123948Ki"
  }
}
```

* pod 메트릭 조회

```bash
$ kubectl get --raw "/apis/metrics.k8s.io/v1beta1/pods"
{
  "kind": "PodMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {},
  "items": [
    {
      "metadata": {
        "name": "metrics-server-596d577f98-zmmfx",
        "namespace": "default",
        "creationTimestamp": "2023-10-08T03:58:08Z",
        "labels": {
          "app.kubernetes.io/instance": "metrics-server",
          "app.kubernetes.io/name": "metrics-server",
          "pod-template-hash": "596d577f98"
        }
      },
      "timestamp": "2023-10-08T03:57:46Z",
      "window": "12.223s",
      "containers": [
        {
          "name": "metrics-server",
          # 메트릭
          "usage": {
            "cpu": "4298535n",
            "memory": "17428Ki"
          }
        }
      ]
    },
  ...
}
```

# 실습 환경 삭제
* kind cluster 삭제

```bash
make uninstall
```

# 참고자료
* Metrics API: https://github.com/feiskyer/kubernetes-handbook/blob/master/en/addons/metrics.md#metrics-api
* Metrics server helm chart: https://github.com/kubernetes-sigs/metrics-server/tree/master/charts
* Kind 디버깅 레벨 설정: https://blog.outsider.ne.kr/1659
* 쿠버네티스 리소스 메트릭 파이프라인 문서: https://kubernetes.io/ko/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
