#!/bin/bash

grpc_tools_ruby_protoc -I ./protos --ruby_out=./client/lib --grpc_out=./client/lib ./protos/messages.proto
grpc_tools_ruby_protoc -I ./protos --ruby_out=./server/lib --grpc_out=./server/lib ./protos/messages.proto