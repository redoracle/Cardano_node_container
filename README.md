# Cardano TestNet Pool - Pool node [![Build Status](https://travis-ci.org/redoracle/jormungandrpt.svg?branch=master)](https://travis-ci.org/redoracle/jormungandrpt)


Requirements:

1) an external folder mapped to the internal container folder used store Node Info and configuration "node-config.yaml".
I used "/home/xxx/DATA/CardanoNodeTest/" 
2) public IP
3) linux server (I use Debian)


Available tools (included in ENV PATH):

Ufficial tool for creating wallet and pools
jtools

Derivate command from jcli:
jstats
jstatx
jshutdown
stop-node 
start-node
start-pool
 
GeoIP netstat watching:
watch_node

----------------------------------------------------------------------
Based on: https://input-output-hk.github.io/jormungandr/jcli/rest.html

STATS
/root/red-jor-test/jcli rest v0 node stats get --host "http://127.0.0.1:3101/api"

HELP
/root/red-jor-test/jcli rest v0 node --help --host "http://127.0.0.1:3101/api"

UTXO
/root/red-jor-test/jcli rest v0 utxo get --host "http://127.0.0.1:3101/api"

STAKE POOLS LIST
/root/red-jor-test/jcli rest v0 stake-pools get --host "http://127.0.0.1:3101/api"

STAKE
/root/red-jor-test/jcli rest v0 stake get --host "http://127.0.0.1:3101/api"


LEADERS
/root/red-jor-test/jcli rest v0 leaders get --host "http://127.0.0.1:3101/api"
/root/red-jor-test/jcli rest v0 leaders post --host "http://127.0.0.1:3101/api"

----------------------------------------------------------------------


---- OUTSIDE THE CONTAINER ----


Example of my node-config.yaml:
-----------------------------------------------
log:
  format: "plain"
  level: "info"
  output: "stderr"
p2p:
  listen_address: "/ip4/0.0.0.0/tcp/3000"
  public_address: "/ip4/xxx.xxx.xxx.xxx/tcp/8299"
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
   - "/ip4/185.161.193.61/tcp/8299"
   - "/ip4/18.139.40.4/tcp/3000"
   - "/ip4/52.57.157.167/tcp/3000"
   - "/ip4/3.123.155.47/tcp/3000"
   - "/ip4/3.115.57.216/tcp/3000"
   - "/ip4/3.112.185.217/tcp/3000"
   - "/ip4/18.139.40.4/tcp/3000"
   - "/ip4/18.140.134.230/tcp/3000"
rest:
  listen: "127.0.0.1:3101"
leadership:
    log_ttl: 1h
    garbage_collection_interval: 15m
mempool:
    fragment_ttl: 30m
    log_ttl: 1h
    garbage_collection_interval: 15m
storage: "/datak/jormungandr"
-----------------------------------------------

Note: xxx.xxx.xxx.xxx is your public IP.

To run:
# docker run -it -d --name Cardano -p 3000:3000 -p 8299:8299 -p 127.0.0.1:3101:3101 -v /path/to/DATA/CardanoNodeTest/:/datak redoracle/jormungandrpt

Get a docker container command line prompt:
# docker exec -it $(docker ps | grep redoracle/jormungandrpt | awk '{print $ 1}') bash

---- INSIDE THE CONTAINER ----

Once inside the container:
1) run the node: 
# start-node

2) run the jcli stats command:
# jstats

3) Use jtools to create a wallet, to create a wallet named Andromeda do:
# jtools  wallet new Andromeda

OUTPUT:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
New wallet Andromeda
public key: ed25519_pk1cewxzq0x6xkzjj3zc3a5885tzvv6pz4uffppdklya20q8j85tt2smkrm0c
address: ca1shr9ccgpumg6c222ytz8ksu73vf3ngy2h39yy9kmun4fuq7g73dd204gv2d
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The wallet files will be stored in:

# ls /datak/wallet/Andromeda/
ed25519.account  ed25519.key  ed25519.pub

4) Use the just gerated address:
ca1shr9ccgpumg6c222ytz8ksu73vf3ngy2h39yy9kmun4fuq7g73dd204gv2d

and requests Faucets from the following website:
https://testnet.iohkdev.io/shelley/tools/faucet/

5) Check your wallet "Andromeda" until you get your balance different from 0
...error...
Balance: 0 Lovelaces
# 

6) Once you get your test tokens you are ready to register the pool:
# jtools pool register PISCINA Andromeda

Where PISCINA is the name of your pool (you will find the poool's keys in /datak/pool/PISCINA/

7) When PISCINA will get accredited you will see your pool id:
for example 09960552cb82036bef1c8d593dbbfb43b4e6be11a5c768ae548d5af5b9e9a402

you will find it in /datak/pool/PISCINA/stake_pool.id along with other files.


*Note: If you change parameter within your node-config.yaml, than please change the stats.sh script accordignly.

---- OUTSIDE THE CONTAINER ----

TO run the commands outside the container use the following:
# docker exec --user root  Cardano "<command>"


USEFUL LINKS: 
----------------------------------------------------
* https://github.com/input-output-hk/shelley-testnet/wiki/How-to-setup-a-Jormungandr-Networking--node-(--v0.5.0)
* https://testnet.iohkdev.io/shelley/tools/faucet/
* https://cardanoupdates.com/resources/
* https://input-output-hk.github.io/jormungandr/jcli/rest.html
* https://github.com/input-output-hk/shelley-testnet/wiki/How-do-I-know-that-my-node-is-in-%60sync%60
----------------------------------------------------
