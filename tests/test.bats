#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-drupal-solr

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site --project-type=drupal9 --docroot=web --php-version=8.1
  assert_success
  run ddev start -y
  assert_success

  echo "# Setting up Drupal project via composer ${PROJNAME} in $(pwd)" >&3
  ddev composer create-project -n --no-install drupal/recommended-project:^9 >/dev/null
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr >/dev/null
  ddev composer config --append -- allow-plugins true
  ddev composer install >/dev/null
  ddev import-db --file=${DIR}/tests/testdata/db.sql.gz >/dev/null
}

health_checks() {
  run ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status'
  assert_success
  assert_output "enabled"

  run ddev drush search-api-solr:reload default_solr_server
  assert_success

  # Make sure the solr admin UI via HTTP from outside is redirected to HTTP /solr/
  run curl -sfI http://${PROJNAME}.ddev.site:8983
  assert_success
  assert_output --partial "HTTP/1.1 302"
  assert_output --partial "Location: http://${PROJNAME}.ddev.site:8983/solr/"

  # Make sure the solr admin UI via HTTPS from outside is redirected to HTTPS /solr/
  run curl -sfI https://${PROJNAME}.ddev.site:8943
  assert_success
  assert_output --partial "HTTP/2 302"
  assert_output --partial "location: https://${PROJNAME}.ddev.site:8943/solr/"

  # Make sure the solr admin UI is working from outside
  run curl -sfL https://${PROJNAME}.ddev.site:8943
  assert_success
  assert_output --partial "Solr Admin"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
