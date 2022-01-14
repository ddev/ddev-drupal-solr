setup() {
  TESTDIR=/tmp/test
  SITENAME=test.ddev.site
  mkdir -p /tmp/test
  ddev config --project-type=drupal9 --docroot=web --create-docroot
  ddev composer create-project -y --no-install drupal/recommended-project
  ddev composer require drush/drush:* drupal/search_api_solr
  ddev composer install
  ddev drush si -y standard --account-pass=admin
  ddev drush en -y search_api_solr_admin
}

@test "basic installation" {
  cd ${TESTDIR}
  ddev service get solr test
  ddev restart test
  curl -I http://${SITENAME}/#solr:8983
}
