Preston server configuration notes.



# add kafka user
```
sudo useradd -r -s /bin/false kafka
```

install kafka in /var/lib/kafka/kafka_[version]/
create symlink to /var/lib/kafka/kafka-current/



```
sudo mkdir -p /var/lib/kafka /var/cache/kafka
sudo chown kafka:kafka /var/lib/kafka /var/cache/kafka
```


zookeeper.service
```
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=kafka
ExecStart=/var/lib/kafka/kafka-current/bin/zookeeper-server-start.sh /var/lib/kafka/kafka-current/config/zookeeper.properties
ExecStop=/var/lib/kafka/kafka-current/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```


```
sudo ln -s /var/lib/kafka/systemd/system/zookeeper.service /lib/systemd/system/zookeeper.service
sudo systemctl daemon-reload
sudo systemctl enable zookeeper.service
```

Kafka service
```
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=kafka
ExecStart=/bin/sh -c '/var/lib/kafka/kafka-current/bin/kafka-server-start.sh /var/lib/kafka/kafka-current/config/server.properties > /var/lib/kafka/kafka-current/kafka.log 2>&1'
ExecStop=/var/lib/kafka/kafka-current/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

```
sudo ln -s /var/lib/kafka/systemd/system/kafka.service /lib/systemd/system/kafka.service
sudo systemctl daemon-reload
sudo systemctl enable kafka.service
```

----
creating topics

sudo -u kafka /var/lib/kafka/kafka-current/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic email

sudo -u kafka /var/lib/kafka/kafka-current/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic arctos


sending message

```
$ echo -e "email\thash://sha256/f55bcfe2fecb108d11246b00ce3ba1a207db2b21a2f143f93e75be45299a66c1" | /var/lib/kafka/kafka-current/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic email 
>>
```

receiving a message

```
$ sudo -u kafka /var/lib/kafka/kafka-current/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic email --from-beginning
email	hash://sha256/f55bcfe2fecb108d11246b00ce3ba1a207db2b21a2f143f93e75be45299a66c1
```
