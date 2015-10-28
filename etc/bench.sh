#!/bin/sh

ab -n 10000 -c 10 -p request.json -T "application/json; charset=utf-8" http://localhost:3000/api/rtb/1.0.0/bid
