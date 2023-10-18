# Ruby on Rails gRPC Example

This is an example Ruby on Rails application that demonstrates how to use gRPC in a Rails project.

## Prerequisites
* Docker 20 or higher
* Docker Compose 1.29 or higher
* Ruby 3.1.2 or higher
* Rails 7.0.3 or higher
* The **bundler** gem (run **gem install bundler** to install)
* The **grpc** gem (run **gem install grpc** to install)
* The **grpc-tools** gem (run **gem install grpc-tools** to install)

## Setup
1. Clone the repository.
2. Navigate to the project directory.
3. Generate `.proto` file with run **./generate_proto.sh**
This will generate two files in the **lib** directory on client and server.

## How to run
First create network, run the following command:

    make create-network
    
To start the Rails server and client, run the following command:

    make start
    
To stop the Rails server and client, run the following command:

    make stop

## How to play
In separated terminal run 

    curl -v \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    -X POST \
    -d ' {"message":"my message awesome example new one"}' \
    http://localhost:8002/messages
