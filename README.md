[![tests](https://github.com/drud/ddev-drupal9-solr/actions/workflows/tests.yml/badge.svg)](https://github.com/drud/ddev-drupal9-solr/actions/workflows/tests.yml)

## What is this?

This repository allows you to quickly install Apache Solr for Drupal 9 into a [Ddev](https://ddev.readthedocs.io) project using just `ddev get drud/ddev-drupal9-solr`.

## Installation on Drupal 9

1. `ddev get drud/ddev-drupal9-solr && ddev restart`
1. You may need to install the relevant Drupal requirements: `ddev composer require drush/drush:* drupal/search_api_solr`
1. Create a search_api server at `admin/config/search/search-api` -> "Add server"
1. Choose Solr as backend.
1. Choose "Standard" as the Solr connector type and configure it:
   * Set "Solr host" to `solr`.
   * Set "Solr core" name to "dev".
   * Under "Advanced server configuration" set the "solr.install.dir" to `/opt/solr`.
1. `ddev restart`

## Explanation

This is the classic Drupal solr:8 recipe used for a long time by Drupal users and compatible with search_api_solr. 

* It installs a [`.ddev/docker-compose.solr.yaml`](docker-compose.solr.yaml) using the solr:8 docker image
* A standard Drupal 9 solr configuration is included in [.ddev/solr/conf](.ddev/solr/conf)
* A [.ddev/docker-entrypoint-initdb.d/solr-configupdate.sh](solr/docker-entrypoint-initdb.d/solr-configupdate.sh) is included and mounted into the solr container so that you can change solr config in .ddev/solr/conf with just a `ddev restart`.

## Interacting with Apache Solr

* The Solr admin interface will be accessible at: `http://<projectname>.ddev.site:8983/solr/` For example, if the project is named `myproject` the hostname will be: `http://myproject.ddev.site:8983/solr/`.
* To access the Solr container from inside the web container use: `http://solr:8983/solr/`
* A Solr core is automatically created by default with the name "dev"; it can be accessed (from inside the web container) at the URL: `http://solr:8983/solr/dev` or from the host at `http://<projectname>.ddev.site:8983/solr/#/~cores/dev`. You can obviously create other cores to meet your needs.

## Caveats
* This recipe won't work with versions of solr before solr:8, and Acquia and Pantheon.io hosting require versions from 3 to 7. You'll want to see the [contributed recipes](https://github.com/drud/ddev-contrib) for older versions of solr.

