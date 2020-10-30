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


