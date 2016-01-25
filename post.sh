#!/bin/bash

curl -H "Content-Type: application/json" --data-binary @post.data http://localhost:9000/api/users
