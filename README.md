# Contracts
Contracts for cartallos


# Install
    docker build -t cartallos .
    docker run -p 8545:8545 -d --name cartallos cartallos
    docker exec -it cartallos truffle deploy

Alternatively, running inside of a VSCode development container allows output of ganache-cli to be seen.