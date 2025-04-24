[![tests](https://github.com/ddev/ddev-drupal-solr/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-drupal-solr/actions/workflows/tests.yml)

## What is the difference between this and ddev-solr

Please consider using [ddev/ddev-solr](https://github.com/ddev/ddev-solr), which runs Solr in the modern "cloud" mode. This offers several advantages. If you are using Drupal, the biggest advantage
is that you can update the Solr Configset from the UI or with a Drush command everytime you update search_api_solr.

The current addon runs in "classic standalone" mode. It is probably simpler at first to setup, but comes with the added maintainance steps for configsets. Most Solr hosting service providers run "Solr Cloud"
as a backend.

## What is this?

This repository allows you to quickly install Apache Solr for Drupal 9+ into a [Ddev](https://ddev.readthedocs.io) project using just `ddev add-on get ddev/ddev-drupal-solr`. It follows the [Setting up Solr (single core) - the classic way](https://git.drupalcode.org/project/search_api_solr/-/blob/4.x/README.md#setting-up-solr-single-core-the-classic-way) recipe.

## Installation on Drupal 9+

1. `ddev add-on get ddev/ddev-drupal-solr && ddev restart`
2. You may need to install the relevant Drupal requirements: `ddev composer require drush/drush drupal/search_api_solr`
3. Enable the `search_api_solr` module either using the web interface or `ddev drush en -y search_api_solr`
4. Create a Search API server at `admin/config/search/search-api` -> "Add server"
5. Create a server with the following settings
   * Set "Server name" to anything you want. Maybe `ddev-solr-server`.
   * Set "Backend" to `Solr`
   * Configure Solr backend
     * Set "Solr Connector" to `Standard`
     * Set "Solr host" to `solr`
     * Set "solr core" to `dev`
     * Under "Advanced server configuration" set the "solr.install.dir" to `/opt/solr`.

6. `ddev restart`

## Outdated Solr config files

If you get a message about Solr having outdated config files, you need to update the included Solr config files.

1. Click "Get config.zip" on the server page
2. Unzip the files, and put the config files into `.ddev/solr/conf/`
3. Run `ddev restart`

### Other frameworks

See [the documentation in the `doc` folder](doc/README.md)

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

```yml
services:
  solr:
    environment:
    - SOLR_CORENAME=somecorename
```
1. Change SOLR_CORENAME environment variable in the `environment:` section.
2. Change your Drupal configuration to use the new core.

You can delete the "dev" core from `http://<projectname>.ddev.site:8983/solr/#/~cores/dev` by clicking "Unload".

## Multiple Solr Cores

If you would like to use more than one Solr core, add a  `.ddev/docker-compose.solr_extra.yaml` to override some of the default configuration.

1. Define a mount point for each core you require. Add new mount points for each core, for example:
```yml
services:
  solr:
    volumes:
    - ./solr:/solr-conf
    - ./core2:/core2-conf
    - ./core3:/core3-conf
```

2. Create the directories for your new cores' config, and copy the desired solr config in to it, eg:
   
   `cp -R .ddev/solr .ddev/core2`
   
   `cp -R .ddev/solr .ddev/core3`
   
   `cp -R path/to/core2-config/* .ddev/core2/conf/`
   
   `cp -R path/to/core3-config/* .ddev/core3/conf/`
   
4. Set the 'entrypoint' value to use `precreate-core` instead of `solr-precreate` and add the additional cores, along with a command to start solr afterwards:
```yml
services:
  solr:
    entrypoint: 'bash -c "VERBOSE=yes docker-entrypoint.sh precreate-core solrconf /solr-conf ; precreate-core core2 /core2-conf ; precreate-core core3 /core3-conf  ; exec solr -f "'
```

5. Your finished [`.ddev/docker-compose.solr_extra.yaml`](docker-compose.solr_extra.yaml) file should now look something like this:
```yml
  services:
  solr:
    volumes:
    - ./solr:/solr-conf
    - ./core2:/core2-conf
    - ./core3:/core3-conf
    entrypoint: 'bash -c "VERBOSE=yes docker-entrypoint.sh precreate-core solrconf /solr-conf ; precreate-core core2 /core2-conf ; precreate-core core3 /core3-conf  ; exec solr -f "'
```
5. Finally, `ddev restart` to pick up the changes and create the new cores.
   
## Caveats

* This recipe won't work with versions of Solr before `solr:8`, and Acquia's hosting [requires Solr 7](https://docs.acquia.com/acquia-search/). You'll want to see the [contributed recipes](https://github.com/ddev/ddev-contrib) for older versions of Solr.
