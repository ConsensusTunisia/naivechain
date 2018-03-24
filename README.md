# Naivechain

### Quick start
Set up two connected nodes and add a block
```
npm install
npm start 3001 6001
npm start 3002 6002 ws://localhost:6001
curl -H "Content-type:application/json" --data '{"data" : "Some data to the first block"}' http://localhost:3001/addBlock
```

### Quick start with Docker
Set up three connected nodes and add a block
###
```
docker-compose up
curl -H "Content-type:application/json" --data '{"data" : "Some data to the first block"}' http://localhost:3001/addBlock
```

### HTTP API
##### Get blockchain
```
curl http://localhost:3001/blocks
```
##### Create block
```
curl -H "Content-type:application/json" --data '{"data" : "Some data to the first block"}' http://localhost:3001/addBlock
```
##### Add peer
```
curl -H "Content-type:application/json" --data '{"peer" : "ws://localhost:6001"}' http://localhost:3001/addPeer
```
#### Query connected peers
```
curl http://localhost:3001/peers
```
