#!/bin/bash

# destroy containers, if any, then triggers docker-compose
all: prune load

# put down every container
down:
	@ docker compose -f srcs/docker-compose.yml down --remove-orphans --volumes

# remove all unused containers, including volumes
prune:	down
	@ docker system prune -af --volumes

# all will triggers docker compose up (create images and launch containers).
load:
	@ docker compose -f srcs/docker-compose.yml up -d --build

PHONY: all load down prune clean
