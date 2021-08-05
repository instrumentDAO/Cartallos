# Contracts
Contracts for cartallos


# Install With Docker
    docker build -t cartallos .
    docker run -p 8545:8545 -d --name cartallos cartallos
    docker exec -it cartallos ganache-cli -s cow
    docker exec -it cartallos ./setup.sh

# Run Without Docker, with ganache-cli
    npm install truffle -g
    npm install -g ganache-cli
    npm install @openzeppelin/contracts
    ganache-cli -s cow
    ./setup.sh

# Run Without Docker, with Ganache GUI
    npm install truffle -g
    npm install @openzeppelin/contracts
At this point run ganache GUI with the following mnemonic: 
    
    border future dirt flag moment goat february law awake achieve lecture tumble

Set the port to 8545, and run the following commands

    truffle deploy
    ./setup.sh

The web3 service will then be running on 127.0.0.1:8545

