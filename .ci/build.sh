#!/bin/bash

[ -n "$TEMP_IMAGE" ] || TEMP_IMAGE="mplx/webvirtcloud"

docker build --tag $TEMP_IMAGE .
