Hello

Requirements:

external folder mapped to the internal continer folder used store Node Info and configuration "node-config.yaml".
I used "/home/xxx/DATA/CardanoNodeTest/"

Example of my node-config.yaml:
-----------------------------------------------
log:
  format: "plain"
  level: "info"
  output: "stderr"
p2p:
  listen_address: "/ip4/0.0.0.0/tcp/3100"
  public_address: "/ip4/xxx.xxx.xxx.xxx/tcp/3100"
  topics_of_interest:
    blocks: "high"
    messages: "high"
  trusted_peers:
    - "/ip4/3.123.177.192/tcp/3000"
    - "/ip4/3.123.155.47/tcp/3000"
    - "/ip4/52.57.157.167/tcp/3000"
    - "/ip4/3.112.185.217/tcp/3000"
    - "/ip4/18.140.134.230/tcp/3000"
    - "/ip4/18.139.40.4/tcp/3000"
    - "/ip4/3.115.57.216/tcp/3000"
rest:
  listen: "127.0.0.1:3101"
storage: "/datak/jormungandr"
-----------------------------------------------

Note: xxx.xxx.xxx.xxx is your public IP.

To run:
docker run -it -d --name Cardano -p 3000:3000 -p 3100:3100 -p 3101:3101 -v /home/xxx/DATA/CardanoNodeTest/:/datak

To get the container id run: 
docker ps

To enter the container:
docker -it <containerid> bash

Once inside the container:
1) run the node: 
/root/red-jor-test/jormungandr --config /datak/node-config.yaml --genesis-block-hash adbdd5ede31637f6c9bad5c271eec0bc3d0cb9efb86a5b913bb55cba549d0770

2) run the jcli stats command:
/root/red-jor-test/jcli rest v0 node stats get --host "http://127.0.0.1:3101/api"

*Note: If you change parameter within your node-config.yaml, than please change the stats.sh script accordignly.


TO run the commands outside the container use the following:



