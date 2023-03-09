# Sandbox

This example contains a fully dockerized sandbox with:
* A 3-node Redpanda cluster
* Redpanda Console
* Prometheus
* Grafana
* Kafka Connect. Used here to showcase the Kafka producer/consumer dashboards
* Owl Shop. A mock e-commerce application that generates data.

### Setup

To get started it is as simple as running the docker compose file:

```commandline
$ cd demo
$ docker-compose up -d
[+] Running 9/9
 ⠿ Network demo_default       Created
 ⠿ Container grafana          Started
 ⠿ Container prometheus       Started
 ⠿ Container redpanda-1       Started
 ⠿ Container redpanda-0       Started
 ⠿ Container redpanda-2       Started
 ⠿ Container demo-owl-shop-1  Started
 ⠿ Container demo-console-1   Started
 ⠿ Container connect          Started
```

You can check the status of the Redpanda cluster using the following command:
```commandline
$ docker exec -it redpanda-0 rpk cluster status
CLUSTER
=======
redpanda.initializing

BROKERS
=======
ID    HOST        PORT
0*    redpanda-0  29092
1     redpanda-1  29093
2     redpanda-2  29094

```
Once the bootstrap is complete, you should see all three nodes running and the cluster's UUID displayed.
```commandline
$docker exec -it redpanda-0 rpk cluster status
CLUSTER
=======
redpanda.initializing

BROKERS
=======
ID    HOST        PORT
0*    redpanda-0  29092
1     redpanda-1  29093
2     redpanda-2  29094

```
You should now be able to open the following URIs in your browser for each service:
- Redpanda Console: [http://localhost:8080/](http://localhost:8080/])
- Prometheus: [http://localhost:9090](http://localhost:9090])
- Grafana: [http://localhost:3000](http://localhost:3000])

Once you log into Grafana, click on the Dashboards icon on the left and select Browse. From there, you should be able to
see the imported dashboards described above.
