# Contracts
Contracts for cartallos


# Install With Docker
    docker build -t cartallos .
    docker run -p 8545:8545 -d --name cartallos cartallos
    docker exec -it cartallos truffle deploy
    docker exec -it cartallos truffle exec ./test/FillPools.js

# Run Without Docker, with ganache-cli
    npm install truffle -g
    npm install -g ganache-cli
    npm install @openzeppelin/contract
    ganache-cli -s cow
    truffle deploy
    truffle exec ./test/FillPools.js

# Run Without Docker, with Ganache GUI
    npm install truffle -g
    npm install @openzeppelin/contract
At this point run ganache GUI with the following mnemonic: 
    
    border future dirt flag moment goat february law awake achieve lecture tumble

Set the port to 8545, and run the following commands

    truffle deploy
    truffle exec ./test/FillPools.js

The web3 service will then be running on 127.0.0.1:8545

stuff
