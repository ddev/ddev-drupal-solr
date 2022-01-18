[![tests](https://github.com/rfay/solr/actions/workflows/tests.yml/badge.svg)](https://github.com/rfay/solr/actions/workflows/tests.yml)

## Installation on Drupal 9

* `ddev service get rfay/solr && ddev restart`
* You may need to install the relevant Drupal requirements: `ddev composer require drush/drush:* drupal/search_api_solr`
* Enable the Search API Solr Search Defaults module: `ddev drush en -y search_api_solr_defaults`. (If it can't be enabled due to the "article" content type not existing, you can just create a search_api_solr server manually.)
* Edit the enabled search_api server named `default_solr_server` at `admin/config/search/search-api/server/default_solr_server/edit`
  * set "Solr host" to `solr`
  * set "Solr core" name to "dev"
  * Under "Advanced server configuration" set the "solr.install.dir" to `/opt/solr`
* `ddev restart`

## Explanation

This is the classic Drupal solr 8 recipe used for a long time by Drupal users and compatible with search_api_solr. 

It installs a `docker-compose.solr.yaml` and a standard downloaded configuration.

## Interacting with Apache Solr

* The Solr admin interface will be accessible at: `http://<projectname>.ddev.site:8983/solr/` For example, if the project is named "_myproject_" the hostname will be: `http://myproject.ddev.site:8983/solr/`.
* To access the Solr container from the web container use: `http://solr:8983/solr/`
* A Solr core is automatically created by default with the name "dev"; it can be accessed (from inside the web container) at the URL: `http://solr:8983/solr/dev` or from the host at `http://<projectname>.ddev.site:8983/solr/#/~cores/dev`. You can obviously create other cores to meet your needs.

## Caveats
* This recipe won't work with versions of solr before solr:8, and Acquia and Pantheon.io hosting seem to require versions from 3 to 7. You'll want to see the [contributed recipes](https://github.com/drud/ddev-contrib) for older versions of solr.
