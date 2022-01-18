setup() {
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=$(mktemp -d -t testsolr-XXXXXXXXXX)
  export PROJNAME=testsolr
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type=drupal9 --docroot=web --create-docroot
  ddev composer create -y -n --no-install drupal/recommended-project
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr
  ddev composer install -n
  ddev import-db --src=${DIR}/tests/testdata/db.sql.gz
}

teardown() {
  cd ${TESTDIR}
  ddev delete -Oy ${DDEV_SITENAME}
  rm -rf ${TESTDIR}
}

@test "basic installation" {
  cd ${TESTDIR}
  ddev service get ${DIR}
  ddev restart
  status=$(ddev exec 'drush sapi-sl --format=json | jq -r .default_solr_server.status')
  [ "${status}" = "enabled" ]
  sleep 10 # After a restart, the solr server may not be ready yet.
  ddev drush search-api-solr:reload default_solr_server
}
