#!/bin/bash

yum deplist $1 | egrep "dependency|provider"
