#!/bin/sh

curl -H "Accept: application/json" -H "Content-type: application/json" -X POST -d @../resources/request.json localhost:3000/api/rtb/1.0.0/bid
