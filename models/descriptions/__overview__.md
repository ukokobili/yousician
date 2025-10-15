{% docs __overview__ %}

# Welcome to the Yousician Marketing Ads Model Documentation

## **What does this documentation cover?**
The documentation included here details the design of the Ad Network tables and views available via [yousician](https://yousician.com/). For more information on how these models are built, please see [the github repository.](https://github.com/ukokobili/yousician)

## **How do I use these docs?**
The easiest way to navigate this documentation is to use the Quick Link below. This link will take you to the documentation for each table, which contains a description, a list of the columns, and other helpful information.

If you are experienced with dbt docs, feel free to use the sidebar to navigate the documentation, as well as explore the relationships between tables and the logic building them.

There is more information on how to use dbt docs in the last section of this document.

## **Quick Link to Table Documentation**

**Click on the links below to jump to the documentation for each schema.**

### Mart Tables (`YOUSICIAN`.`MART`.`<table_name>`)

**Fact Table:**
- [fct__geo_marketing_performance](#!/model/model.yousician.fct__ae_ad_network_geo_performance)


## **Data Model Overview**

The Ad Network models are built a few different ways, but the mart fact tables are built using three layers of sql models: **staging, intermidate, and mart.**

- Staging: Data is loaded in from the source as a view with light transformation.
- Intermediate: All necessary parsing, filtering, de-duping, and other transformations are done here.
- Mart: Final tables that are available for the end user

The dimension tables are sourced from Yousician's Backend sources.


## **Using dbt docs**
### Navigation

You can use the ```Project``` and ```Database``` navigation tabs on the left side of the window to explore the models in the project.

### Database Tab

This view shows relations (tables and views) grouped into database schemas. Note that ephemeral models are *not* shown in this interface, as they do not exist in the database.

### Graph Exploration

You can click the blue icon on the bottom-right corner of the page to view the lineage graph of your models.

On model pages, you'll see the immediate parents and children of the model you're exploring. By clicking the Expand button at the top-right of this lineage pane, you'll be able to see all of the models that are used to build, or are built from, the model you're exploring.

Once expanded, you'll be able to use the ```--models``` and ```--exclude``` model selection syntax to filter the models in the graph. For more information on model selection, check out the [dbt docs](https://docs.getdbt.com/docs/model-selection-syntax).

Note that you can also right-click on models to interactively filter and explore the graph.


### **More information**
- [Yousician](https://yousician.com/)
- [What is dbt?](https://docs.getdbt.com/docs/introduction)


{% enddocs %}