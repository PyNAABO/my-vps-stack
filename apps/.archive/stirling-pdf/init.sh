#!/bin/bash
mkdir -p "$(dirname "$0")/../../config/stirling-pdf/trainingData"
mkdir -p "$(dirname "$0")/../../config/stirling-pdf/extraConfigs"
mkdir -p "$(dirname "$0")/../../config/stirling-pdf/logs"
chown -R 1000:1000 "$(dirname "$0")/../../config/stirling-pdf"
