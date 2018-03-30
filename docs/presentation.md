# 1. What is blockchain
Blockchain is a continuously growing list of records, called blocks, which are linked and secured from tampering using cryptography. It is a distributed ledger that can record data between different parties. ([Wikipedia](https://en.wikipedia.org/wiki/Blockchain))

# 2. Keywords
- List of blocks
![](https://image.ibb.co/iX3mh7/blocks.png)
- No tampering: The data can't be tampered once it's added
![](https://image.ibb.co/mtJJ27/blockchains.png)
- Distributed ledger: A blockchain is typically managed by a peer-to-peer network and each node has a copy of the blockchain.

![](https://cdn57.androidauthority.net/wp-content/uploads/2017/09/In-a-p2p-network-no-centralized-server.jpg)

# 3. Node main components
1. The node has a copy of the blockchain.
2. The node can add data into the blockchain.
3. The node can communicate with other nodes.

![](https://image.ibb.co/e9i8en/node_components.png)

# 4. Block structure
The block contains:
- **Index**
-  **Data**
- **Time**: The time of the creation
-  **Previous Hash**: The hash of the previous block
-  **Hash**: HASH(index + previousHash + time + data)

```
class Block {
    constructor(index, previousHash, timestamp, data, hash) {
        this.index = index;
        this.previousHash = previousHash.toString();
        this.timestamp = timestamp;
        this.data = data;
        this.hash = hash.toString();
    }
}                                                                                              
```

# 5. Generating a block                                                                        
To generate a block we must have the list of the rquired parameters:                           

- index: previousIndex + 1                                                                     
- data: The data that we want to store                                                         
- timestamp: It's the current timestamp                                                        
- previousHash: The hash of the previous block                                                 
- hash:
    ```
    var calculateHash = (index, previousHash, timestamp, data) => {
        return CryptoJS.SHA256(index + previousHash + timestamp + data).toString();
    };
    ```
```
var generateNextBlock = (blockData) => {
    var previousBlock = getLatestBlock();
    var nextIndex = previousBlock.index + 1;
    var nextTimestamp = Math.floor(new Date().getTime() / 1000);
    var nextHash = calculateHash(nextIndex, previousBlock.hash, nextTimestamp, blockData);
    return new Block(nextIndex, previousBlock.hash, nextTimestamp, blockData, nextHash);
};
```

# 6. Genesis block
A genesis block is the first block of a blockchain. This block is hardcoded.
```
var getGenesisBlock = () => {
    return new Block(0, "0", 1465154705, "my genesis block!!", "816534932c2b7154836da6afc367695e6337db8a921823784c14378abed4f7d7");
};
```
- index is 0
- previousHash is "0"
- timestamp is 1465154705 (2016-06-05 19:25:05)
- data is "my genesis block!!"
- hash is "816534932c2b7154836da6afc367695e6337db8a921823784c14378abed4f7d7"

# 7. Validating the integrity of blocks
Before adding the block, we should check its integrity.
```
var isValidNewBlock = (newBlock, previousBlock) => {
    if (previousBlock.index + 1 !== newBlock.index) {
        console.log('invalid index');
        return false;
    } else if (previousBlock.hash !== newBlock.previousHash) {
        console.log('invalid previoushash');
        return false;
    } else if (calculateHashForBlock(newBlock) !== newBlock.hash) {
        console.log(typeof (newBlock.hash) + ' ' + typeof calculateHashForBlock(newBlock));
        console.log('invalid hash: ' + calculateHashForBlock(newBlock) + ' ' + newBlock.hash);
        return false;
    }
    return true;
};
```

# 8. Communicating with other nodes
An essential part of a node is to share and sync the blockchain with other nodes. The following rules are used to keep the network in sync.
- When a node generates a new block, it broadcasts it to the network
- When a node connects to a new peer it queries for the latest block
- When a node encounters a block that has an index larger than the current known block, it either adds the block the its current chain or queries for the full blockchain.
![](https://cdn-images-1.medium.com/max/800/1*sz2iVHdWBdtwNl3npeLddQ.png)

```
var initP2PServer = () => {
    var server = new WebSocket.Server({port: p2p_port, host: host});
    server.on('connection', ws => initConnection(ws));
    console.log('listening websocket p2p port on: ' + p2p_port);

};

var connectToPeers = (newPeers) => {
    newPeers.forEach((peer) => {
        var ws = new WebSocket(peer);
        ws.on('open', () => initConnection(ws));
        ws.on('error', () => {
            console.log('connection failed')
        });
    });
};
```

# 9. Controlling the node
The user must be able to control the node in some way. This is done by setting up a HTTP server.
```
var initHttpServer = () => {
    var app = express();
    app.set('views', __dirname);
    app.engine('html', require('ejs').renderFile);
    app.set('view engine', 'html');
    app.use(bodyParser.urlencoded({extended: true}));
    app.use(bodyParser.json());

    app.get('/', (req, res) => res.render('index.html', {
      peers: sockets.map(s => s._socket.remoteAddress + ':' + s._socket.remotePort),
      blocks: blockchain
    }));
    app.get('/blocks', (req, res) => res.send(JSON.stringify(blockchain)));
    app.post('/addBlock', (req, res) => {
        var newBlock = generateNextBlock(req.body.data);
        addBlock(newBlock);
        broadcast(responseLatestMsg());
        console.log('block added: ' + JSON.stringify(newBlock));
        res.redirect('/');
    });
    app.get('/peers', (req, res) => {
        res.send(sockets.map(s => s._socket.remoteAddress + ':' + s._socket.remotePort));
    });
    app.post('/addPeer', (req, res) => {
        connectToPeers([req.body.peer]);
        res.send();
    });
    app.listen(http_port, host, () => console.log('Listening http on port: ' + http_port));
};
```

# 10. Node architecture
![](https://image.ibb.co/fvTSN7/arch.png)
