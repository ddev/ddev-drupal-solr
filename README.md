[![tests](https://github.com/ddev/ddev-drupal9-solr/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-drupal9-solr/actions/workflows/tests.yml)

## What is this?

This repository allows you to quickly install Apache Solr for Drupal 9+ into a [Ddev](https://ddev.readthedocs.io) project using just `ddev get ddev/ddev-drupal9-solr`. It follows the [Setting up Solr (single core) - the classic way](https://git.drupalcode.org/project/search_api_solr/-/blob/4.x/README.md#setting-up-solr-single-core-the-classic-way) recipe.

## Installation on Drupal 9+

1. `ddev get ddev/ddev-drupal9-solr && ddev restart`
2. You may need to install the relevant Drupal requirements: `ddev composer require drush/drush:* drupal/search_api_solr`
3. Enable the `search_api_solr` module either using the web interface or `ddev drush en -y search_api_solr`
4. Create a search_api server at `admin/config/search/search-api` -> "Add server"
5. Create a server with the following settings
   * Set "Server name" to anything you want. Maybe `ddev-solr-server`.
   * Set "Backend" to `Solr`
   * Configure Solr backend
     * Set "Solr Connector" to `Standard`
     * Set "Solr host" to `solr`
     * Set "solr core" to `dev`
     * Under "Advanced server configuration" set the "solr.install.dir" to `/opt/solr`.

6. `ddev restart`

## Installation on Silverstripe 4+

1. `ddev get ddev/ddev-drupal9-solr && ddev restart`
2. Install the required/relevant Silverstripe requirements: `ddev composer require firesphere/solr-search`
    * Note that there are currently some tricky dependencies. This is known and to be fixed soon (tm)
4. Solr is set to use the FileConfigStore. Ensure it's data location is at `.ddev/solr` and the host is set to `solr`:
```yml
---
Name: LocalSolrSearch
After:
  - 'SolrSearch'
Only:
  environment: 'dev'
---
Firesphere\SolrSearch\Services\SolrCoreService:
  config:
    endpoint:
      localhost:
        host: solr
  store:
    path: './.ddev/solr'
Firesphere\SolrSearch\Indexes\BaseIndex:
  dev:
    Classes:
      - Page
    FulltextFields:
      - Title
      - Content
```
5. Edit `.ddev/docker-compose.solr.yml` and on line 60, change `- ./solr:/solr-conf` to `- ./solr/dev:/solr-conf`
    * Historically, Silverstripe uses the name of the core as sub-folder for the location of the core, which is why the location in the YML needs updating.
    * [Refer to the documentation of the Silverstripe Solr module](https://firesphere.github.io/solr-docs/) for how to configure it.
6. Run the Silverstripe Solr configuration command `ddev exec vendor/bin/sake dev/tasks/SolrConfigureTask` or with the ddev-contrib add-on installed `ddev sake dev/tasks/SolrConfigureTask`
7. Restart ddev with `ddev restart`
8. Now your core configuration should be visible in Solr by visiting {yourproject}.ddev.site:8983, and check the schema for `dev`
9. Now you can add documents, update your index, etc. according to the documentation.
  * **NOTE** You will need to restart your solr engine, or the Solr container in its entirety, every time you change your core configuration.
  * **NOTE** Be aware you'll need to either rename or copy your Solr configuration, for production environments and update it as such.

#### Alternate core name in Silverstripe

In Silverstripe, using an alternate/different core name is a matter of changing the mount point in the `.ddev/docker-compose.solr.yml` configuration.

## Explanation

This is the classic Drupal `solr:8` image recipe used for a long time by Drupal users and compatible with `search_api_solr`.

* It installs a [`.ddev/docker-compose.solr.yaml`](docker-compose.solr.yaml) using the solr:8 docker image.
* A standard Drupal 9+ Solr configuration is included in [.ddev/solr/conf](solr/conf).
* A [.ddev/docker-entrypoint-initdb.d/solr-configupdate.sh](solr/docker-entrypoint-initdb.d/solr-configupdate.sh) is included and mounted into the Solr container so that you can change Solr config in `.ddev/solr/conf` with just a `ddev restart`.

## Interacting with Apache Solr

* The Solr admin interface will be accessible at: `http://<projectname>.ddev.site:8983/solr/` For example, if the project is named `myproject` the hostname will be: `http://myproject.ddev.site:8983/solr/`.
* To access the Solr container from inside the web container use: `http://solr:8983/solr/`
* A Solr core is automatically created by default with the name "dev"; it can be accessed (from inside the web container) at the URL: `http://solr:8983/solr/dev` or from the host at `http://<projectname>.ddev.site:8983/solr/#/~cores/dev`. You can obviously create other cores to meet your needs.

## Alternate Core Name

If you want to use a core name other than the default "dev", add a `.ddev/docker-compose.solr-env.yaml` with these contents, using the core name you want to use:

```
services:
  solr:
    environment:
    - SOLR_CORENAME=somecorename
```

1. Remove the #ddev-generated at the top of the file.
2. Change SOLR_CORE environment variable in the `environment:` section.
3. Change your Drupal configuration to use the new core.

## Caveats

* This recipe won't work with versions of Solr before `solr:8`, and Acquia and Pantheon.io hosting require versions from 3 to 7. You'll want to see the [contributed recipes](https://github.com/ddev/ddev-contrib) for older versions of solr.
