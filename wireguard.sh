#!/bin/bash


dnf update -y
dnf install -y elrepo-release epel-release
dnf install -y kmod-wireguard wireguard-tools
