# Installation and usage on Silverstripe 4+

1. `ddev add-on get ddev/ddev-drupal9-solr && ddev restart`
2. Install the required/relevant Silverstripe requirements: `ddev composer require firesphere/solr-search`
    * Note that there are currently some known issues around Guzzle dependencies in the module, that are currently in the process of being resolved.
3. Solr is set to use the FileConfigStore. Ensure its data location is at `.ddev/solr` and the host is set to `solr`:
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
4. Edit `.ddev/docker-compose.solr.yml` and on line 60, change `- ./solr:/solr-conf` to `- ./solr/{your-core-name}:/solr-conf`
    * Historically, Silverstripe uses the name of the core as sub-folder for the location of the core, which is why the location in the YML needs updating.
    * [Refer to the documentation of the Silverstripe Solr module](https://firesphere.github.io/solr-docs/) for how to configure it.
    * Remove the `#ddev-generated` line from the yml.
5. Run the Silverstripe Solr configuration command `ddev exec sake dev/tasks/SolrConfigureTask` or with the ddev-contrib add-on installed `ddev sake dev/tasks/SolrConfigureTask`
6. Restart ddev with `ddev restart`
7. Now your core configuration should be visible in Solr by visiting {yourproject}.ddev.site:8983, and check the schema for `dev`*
8. Now you can add documents, update your index, etc. [as per the documentation](https://firesphere.github.io/solr-docs/).
* **NOTE** You will need to restart your solr engine, every time you change your core configuration with `ddev restart`.
* **NOTE** Be aware you'll need to either rename or copy your Solr configuration, for production environments and update it as such.

## Core name in Silverstripe

At point 7, it is mentioned that the core will be named `dev` in the Solr administration interface. This is because the mountpoint
from the YML is updated to take the Silverstripe generated Solr configuration and treat it as if it is the `dev` core.

In Silverstripe, if you change the name of your core, you will also have to update the mount point in the `.ddev/docker-compose.solr.yml` configuration (point 4 above).
