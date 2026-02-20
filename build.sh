#!/bin/sh

cd _build && exec make -j`nproc`
