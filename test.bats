setup() {
  TESTDIR=~/tmp/test
  SITENAME=test.ddev.site
  DDEV_NON_INTERACTIVE=true
  mkdir -p ${TESTDIR} && cd "${TESTDIR}"
  ddev config --project-type=drupal9 --docroot=web --create-docroot
  ddev composer create -y drupal/recommended-project
  ddev composer require drush/drush:* drupal/search_api_solr
  ddev composer install
  ddev drush si -y standard --account-pass=admin
  ddev drush en -y search_api_solr_admin
}

teardown() {
    ddev delete -Oy test
    rm -rf ${TESTDIR}
}

@test "basic installation" {
  pushd ${TESTDIR} >/dev/null
  ddev service get solr
  ddev restart
  curl -I -H "Host: ${SITENAME}" http://${SITENAME}/#solr:8983
}
