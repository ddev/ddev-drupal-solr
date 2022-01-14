setup() {
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  TESTDIR=~/tmp/test
  SITENAME=test.ddev.site
  export DDEV_NON_INTERACTIVE=true
  mkdir -p ${TESTDIR} && cd "${TESTDIR}"
  ddev config --project-type=drupal9 --docroot=web --create-docroot --mutagen-enabled
  ddev composer create -y -n --no-install drupal/recommended-project
  ddev composer require -n --no-install drush/drush:* drupal/search_api_solr
  ddev composer install -n
  ddev drush si -y minimal --account-pass=admin
  ddev drush en -y search_api_solr_admin
}

teardown() {
    ddev delete -Oy test
    rm -rf ${TESTDIR}
}

@test "basic installation" {
  pushd ${TESTDIR} >/dev/null
  ddev service get ${DIR}
  ddev restart
  curl -I -H "Host: ${SITENAME}" http://${SITENAME}/#solr:8983
}
