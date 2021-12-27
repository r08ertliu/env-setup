#!/bin/bash

sed "s/name =.*/name =/; s/email =.*/email =/" "$@"
