setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-drupal9-solr-test
  mkdir -p $TESTDIR
  export PROJNAME=solrtest
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot
  echo "# Setting up Drupal project via composer ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev composer create -y -n --no-install drupal/recommended-project
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr
  ddev composer config --append -- allow-plugins true
  ddev composer install
  ddev import-db --src=${DIR}/tests/testdata/db.sql.gz
}

teardown() {
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get drud/ddev-drupal9-solr with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  status=$(ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status')
  [ "${status}" = "enabled" ]
  ddev drush search-api-solr:reload default_solr_server
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get drud/ddev-drupal9-solr with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get drud/ddev-drupal9-solr
  ddev restart
  status=$(ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status')
  [ "${status}" = "enabled" ]
  ddev drush search-api-solr:reload default_solr_server
}
