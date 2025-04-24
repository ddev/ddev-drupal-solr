[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/ddev/ddev-drupal-solr/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/ddev/ddev-drupal-solr/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/ddev/ddev-drupal-solr)](https://github.com/ddev/ddev-drupal-solr/commits)
[![release](https://img.shields.io/github/v/release/ddev/ddev-drupal-solr)](https://github.com/ddev/ddev-drupal-solr/releases/latest)

# DDEV Drupal Solr

## What is the difference between this and ddev-solr

Please consider using [ddev/ddev-solr](https://github.com/ddev/ddev-solr), which runs Solr in the modern "Cloud" mode. This offers several advantages. If you are using Drupal, the biggest advantage
is that you can update the Solr Configset from the UI or with a Drush command everytime you update `search_api_solr`.

The current addon runs in "classic standalone" mode. It is probably simpler at first to setup, but comes with the added maintainance steps for configsets. Most Solr hosting service providers run "Solr Cloud" as a backend.

## Overview

[Apache Solr](https://solr.apache.org/) is the blazing-fast, open source, multi-modal search platform built on the full-text, vector, and geospatial search capabilities of Apache Lucene™.

This add-on integrates Solr for Drupal 9+ into your [DDEV](https://ddev.com/) project. It follows the [Setting up Solr (single core) - the classic way](https://git.drupalcode.org/project/search_api_solr/-/blob/4.x/README.md#setting-up-solr-single-core-the-classic-way) recipe.

## Installation on Drupal 9+

1. ```bash
   ddev add-on get ddev/ddev-drupal-solr
   ddev restart
   ```
2. You may need to install the relevant Drupal requirements:
   ```bash
   ddev composer require drush/drush drupal/search_api_solr
   ```
3. Enable the `search_api_solr` module either using the web interface or
   ```bash
   ddev drush en -y search_api_solr
   ```
4. Create a Search API server at `admin/config/search/search-api` -> "Add server"
5. Configure the server with the following settings:
   * Set "Server name" to anything you want. Maybe `ddev-solr-server`.
   * Set "Backend" to `Solr`
   * Configure Solr backend
     * Set "Solr Connector" to `Standard`
     * Set "Solr host" to `solr`
     * Set "solr core" to `dev`
     * Under "Advanced server configuration" set the "solr.install.dir" to `/opt/solr`.
6. `ddev restart`

## Installation on Drupal 7

### Ddev / Solr configuration

1. Install this add-on: `ddev add-on get ddev/ddev-drupal-solr`
2. Set the version of Solr version 7: Edit the `.ddev/docker-compose.solr.yaml` file. Replace `image: solr:8` with `image: solr:7` on line 34.
3. Add the schema needed for version 7: Defaults can be found in the Search API Solr in the `search_api_solr/solr-conf/7.x` directory . Copy these files into `.ddev/solr/conf`.
4. Restart Ddev: `ddev restart`.
5. Confirm Solr is working by visiting `http://<projectname>.ddev.site:8983/solr/`.
6. If the Ddev drush version is too new for Drupal 7, you may need to symlink `drush` to the `drush8` provided with Ddev. You can do this by adding a `post-start` hook inside your `.ddev/config.yaml` file as follows
  ```
  hooks:
    post-start:
    - exec: ln -s /usr/local/bin/drush8 /usr/local/bin/drush
  ```
7. Restart Ddev: `ddev restart`.

### Drupal configuration

1. You may need to install the relevant Drupal modules: `ddev drush dl search_api_solr`.
2. Enable the `search_api_solr` module either using the web interface or `ddev drush en -y search_api_solr`
4. Create a Search API server at `admin/config/search/search-api` -> "Add server"
5. Configure the server with the following settings:
   * Set "Server name" to anything you want. Maybe `ddev-solr-server`.
   * Set "Protocol" to `http`
   * Set "Solr host" to `solr`
   * Set "Solr port" to `8983`
   * Set "path" to `/solr/dev`.
   The "Solr server URI" should be `http://solr:8983/solr/dev` when done.
6. Create a Search API index at `admin/config/search/search-api` -> "Add index"
7. Configure the index as needed, but this is common:
   * Set "Server name" to anything you want. Maybe `ddev-solr-index-content`.
   * Set "item type" to `content`
   * Set the server to `ddev-solr-server` (or whaver the name is)
   * Index the site.
8. Build a new view of indexed content `ddev-solr-index-content` (or whatever the name is)
7. Configure the view as needed, but this is common:
   * Set "View name" to anything you want. Maybe `Solr Search`.
   * Set "Show" to `ddev-solr-index-content` (or whatever the name is)
   * Tick the box for "Create a page"
     * Set the "Page title" to `Search` or whatever you prefer
     * Set the "Path" to `/search` or whatever you prefer
     * Set "Display format" to `HTML list` + `OL` / `Rendered entity` + `Search result` view mode
   * Continue and edit
   * Add filters:
     * Add an EXPOSED filter for `Search: Fulltext search (exposed)`
     * Add additional filters as needed (recommended: `Indexed Content: Status (= Published)`)
   * Add sort criteria:
     * Add a sort on `Search: Relevance (desc)`
   * Set "access control: to `Permission` / `View published content`
   * Set "Exposed form style" to `Input required`
   * Set "No Results behavior" to `Global:text` / `No results matched your search.`
   * (Optional) Set "Exposed form in block" setting

## Outdated Solr config files

If you get a message about Solr having outdated config files, you need to update the included Solr config files.

### Drupal 9+:

1. Click "Get config.zip" on the server page
2. Unzip the files, and put the config files into `.ddev/solr/conf/`
3. Restart Ddev: `ddev restart`

### Drupal 7

1. Locate the example files in the `search_api_solr/solr-conf/7.x` directory .
2. Copy these files into `.ddev/solr/conf`.
4. Restart Ddev: `ddev restart`.

### Other frameworks

See [the documentation in the `doc` folder](doc/README.md)

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev launch :8943` | Open Solr Admin (HTTPS) in your browser (`https://<project>.ddev.site:8943`) |
| `ddev launch :8983` | Open Solr Admin (HTTP) in your browser (`http://<project>.ddev.site:8983`) |
| `ddev describe` | View service status and used ports for Solr |
| `ddev logs -s solr` | Check Solr logs |

## Explanation

This originates from the classic Drupal `solr:8` image recipe used for a long time by Drupal users and compatible with `search_api_solr`.

* This add-on installs a [`.ddev/docker-compose.solr.yaml`](docker-compose.solr.yaml) using the `solr:8` docker image.
* A standard Drupal 9+ Solr configuration is included in [.ddev/solr/conf](solr/conf).
* A [.ddev/docker-entrypoint-initdb.d/solr-configupdate.sh](solr/docker-entrypoint-initdb.d/solr-configupdate.sh) is included and mounted into the Solr container so that you can change Solr config in `.ddev/solr/conf` with just a `ddev restart`.

## Interacting with Apache Solr

* The Solr Admin interface will be accessible at: `https://<projectname>.ddev.site:8943/solr/` and `http://<projectname>.ddev.site:8983/solr/`. For example, if the project is named `myproject` the hostname will be: `https://myproject.ddev.site:8943/solr/`.
* To access the Solr container from inside the web container use: `http://solr:8983/solr/`
* A Solr core is automatically created by default with the name "dev"; it can be accessed (from inside the web container) at the URL: `http://solr:8983/solr/dev` or from the host at `https://<projectname>.ddev.site:8943/solr/#/~cores/dev`. You can obviously create other cores to meet your needs.

## Alternate Core Name

If you want to use a core name other than the default "dev", add a `.ddev/docker-compose.solr-env.yaml` with these contents, using the core name you want to use:

```yaml
services:
  solr:
    environment:
      - SOLR_CORENAME=somecorename
```

1. Change `SOLR_CORENAME` environment variable in the `environment:` section.
2. Change your Drupal configuration to use the new core.

You can delete the "dev" core from `https://<projectname>.ddev.site:8943/solr/#/~cores/dev` by clicking "Unload".

## Multiple Solr Cores

If you would like to use more than one Solr core, add a  `.ddev/docker-compose.solr_extra.yaml` to override some of the default configuration.

1. Define a mount point for each core you require. Add new mount points for each core, for example:

    ```yaml
    services:
      solr:
        volumes:
          - ./solr:/solr-conf
          - ./core2:/core2-conf
          - ./core3:/core3-conf
    ```

2. Create the directories for your new cores' config, and copy the desired solr config in to it, eg:

    ```bash
    cp -R .ddev/solr .ddev/core2
    cp -R .ddev/solr .ddev/core3
    cp -R path/to/core2-config/* .ddev/core2/conf/
    cp -R path/to/core3-config/* .ddev/core3/conf/
    ```

3. Set the `entrypoint` value to use `precreate-core` instead of `solr-precreate` and add the additional cores, along with a command to start solr afterwards:

    ```yaml
    services:
      solr:
        entrypoint: 'bash -c "VERBOSE=yes docker-entrypoint.sh precreate-core solrconf /solr-conf ; precreate-core core2 /core2-conf ; precreate-core core3 /core3-conf  ; exec solr -f "'
    ```

4. Your finished `.ddev/docker-compose.solr_extra.yaml` file should now look something like this:

    ```yaml
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

* This recipe won't work with versions of Solr before `solr:8`, and Acquia's hosting [requires Solr 7](https://docs.acquia.com/acquia-cloud-platform/docs/features/acquia-search). You'll want to see the [contributed recipes](https://github.com/ddev/ddev-contrib) for older versions of Solr.

## Credits

**Contributed by [@rfay](https://github.com/rfay)**

**Maintained by [@mkalkbrenner](https://github.com/mkalkbrenner), [@bserem](https://github.com/bserem), and the [DDEV team](https://ddev.com/support-ddev/)**
