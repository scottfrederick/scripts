#!/bin/bash

sudo systemctl stop cups-browsed 
sudo systemctl disable cups-browsed
sudo apt purge cups-browsed
