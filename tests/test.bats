setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-drupal9-solr-test
  mkdir -p $TESTDIR
  export PROJNAME=solrtest
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot --php-version=8.1
  echo "# Setting up Drupal project via composer ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev composer create -y -n --no-install drupal/recommended-project:^9 >/dev/null
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr >/dev/null
  ddev composer config --append -- allow-plugins true
  ddev composer install >/dev/null
  ddev import-db --src=${DIR}/tests/testdata/db.sql.gz >/dev/null
}

teardown() {
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get drud/ddev-drupal9-solr with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR} >/dev/null
  ddev restart >/dev/null
  status=$(ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status')
  [ "${status}" = "enabled" ]
  ddev drush search-api-solr:reload default_solr_server >/dev/null
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get drud/ddev-drupal9-solr with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get drud/ddev-drupal9-solr >/dev/null
  ddev restart >/dev/null
  status=$(ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status')
  [ "${status}" = "enabled" ]
  ddev drush search-api-solr:reload default_solr_server
}
