#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_override="${tmp_dir}/comments-test-override.yml"
tmp_site="${tmp_dir}/site"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
giscus_post="${repo_root}/_posts/2001-01-01-integration-giscus-comments.md"
disqus_post="${repo_root}/_posts/2001-01-02-integration-disqus-comments.md"

cleanup() {
  rm -rf "${tmp_dir}"
  rm -f "${giscus_post}" "${disqus_post}"
}
trap cleanup EXIT

cat >"${tmp_override}" <<'YAML'
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
external_sources: []
YAML

cat >"${giscus_post}" <<'MARKDOWN'
---
layout: post
title: Integration Giscus Comments
date: 2001-01-01
permalink: /comments/integration-giscus/
giscus_comments: true
---
Temporary post used by integration tests.
MARKDOWN

cat >"${disqus_post}" <<'MARKDOWN'
---
layout: post
title: Integration Disqus Comments
date: 2001-01-02
permalink: /comments/integration-disqus/
disqus_comments: true
---
Temporary post used by integration tests.
MARKDOWN

bundle exec jekyll build --config "_config.yml,${tmp_override}" -d "${tmp_site}" >/dev/null

giscus_page="${tmp_site}/comments/integration-giscus/index.html"
disqus_page="${tmp_site}/comments/integration-disqus/index.html"

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
