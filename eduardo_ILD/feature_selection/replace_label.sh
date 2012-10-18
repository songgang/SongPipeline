#!/bin/bash

# replace the label in multi-label mask image A with binary6 mask image B
# so that A(B=1) = k, k is a new label

# C = A*(1-B) + k * B

C3D=/home/songgang/mnt/pkg/bin/c3d

A=$1
B=$2
k=$3
C=$4

$C3D $B -scale -1 -shift 1 $A -multiply $B -scale $k -add -o $4
