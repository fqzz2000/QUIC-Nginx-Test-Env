#!/bin/bash

docker run -it --rm --network host ymuski/curl-http3 curl "$@"