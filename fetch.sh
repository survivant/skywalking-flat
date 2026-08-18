#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Fetch protocol definitions that Apache SkyWalking normally keeps as git submodules.
# This flattened fork removed .gitmodules; without these trees Maven fails with errors
# such as: cannot find symbol  class Command
#
# Usage (from repository root):
#   bash tools/fetch-protocols.sh
#

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

clone_into() {
  local url="$1"
  local dest="$2"
  local marker="$3"

  if [[ -e "${dest}/${marker}" ]]; then
    echo "[ok] already present: ${dest}"
    return 0
  fi

  echo "[fetch] ${url} -> ${dest}"
  rm -rf "${dest}"
  mkdir -p "$(dirname "${dest}")"
  git clone --depth 1 "${url}" "${dest}"
  rm -rf "${dest}/.git"
}

# Agent/OAP data collect protocol (generates org.apache.skywalking.apm.network...Command etc.)
clone_into \
  "https://github.com/apache/skywalking-data-collect-protocol.git" \
  "apm-protocol/apm-network/src/main/proto" \
  "common/Command.proto"

# GraphQL query schema used by query-graphql-plugin
clone_into \
  "https://github.com/apache/skywalking-query-protocol.git" \
  "oap-server/server-query-plugin/query-graphql-plugin/src/main/resources/query-protocol" \
  "common.graphqls"

# BanyanDB client protos (protoSourceRoot = src/main/proto/proto)
clone_into \
  "https://github.com/apache/skywalking-banyandb-client-proto.git" \
  "oap-server/server-library/library-banyandb-client/src/main/proto" \
  "proto"

# E2E test service (optional tree)
if [[ -d "test/e2e-v2/java-test-service/e2e-protocol" ]]; then
  clone_into \
    "https://github.com/apache/skywalking-data-collect-protocol.git" \
    "test/e2e-v2/java-test-service/e2e-protocol/src/main/proto" \
    "common/Command.proto"
fi

echo
echo "Protocols ready. You can build with:"
echo "  mvn -Pbackend clean install -DskipTests"
