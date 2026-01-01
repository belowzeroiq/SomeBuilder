#!/bin/bash

set_requirements() {
  clear
  mkdir out
  mkdir out/target
  mkdir out/target/product
  mkdir out/target/product/tapas
  mkdir out/target/product/tapas/obj
  mkdir out/target/product/tapas/obj/KERNEL_OBJ
  mkdir out/target/product/tapas/obj/KERNEL_OBJ/usr
}

set_requirements
echo "Device requirements set successfully."
