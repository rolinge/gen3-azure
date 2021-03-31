Explanation of the VALUES file that drives the helm config.

Make sure to edit the following elements in your values*.yaml file.
The following values can be edited.  Those that are required to be edited will be listed in bold.  Those that have a depndancy on other varaibles will also be noted.

Section  | Identifier  | Explanation
--|---|--
Environment  | ENV:  | A moniker given to name your specic environment, like maybe DEV, TEST, etc.
Postgres server  | database_servername:  |  Terraform build a postgres server for you, place its name here
**fence**  |   |  [CDIS documentation](https://github.com/uc-cdis/fence/blob/master/README.md)
| | fence.database.username: | The fence database username
|  |  fence.database.db_password: | database password
|  |  fence.enabledIDPProviders: | Docuemnted in fence github. Select one or more
|  |  fence.base_url: |   This is used in all the fence setup, set to the address you expect to have the web site hosted at.  (the web site URL)
|  | fence.googleOauth:  | if using google auth, follow directions from fence team  |
|  |fence.microsoftOauth:  | If using Microsoft auth, follow directions from fence team
 | |fence.oktaOauth:  | If using OKTA auth, follow directions from fence team
 | | fence.defaultLoginURLSuffix: | The callback URL for your IDP.  Usually set to 'login/\<provider\>'  |
|  | fence.amazonStorageCreds:  | Probably don't need these since using Azure, but they are there if you want to have a cross cloud infra
|  | fence.azCredentials:  | Need the login name and secret key for the Azure blob storage where files will be kept. There can be more than one.
 | | fence.azureBlobstores: | Name of the blob store container and which creds to use.
 | fence.dataUploadBucket:  |  Pointer to which container(Azure) or bucket(AWS) that you want uploads to go to
 | fence.adminUsers: | A list of people with elevated priveleges
 | fence.regularUsers: | A list of people with regular priveleges
 | cacrtFiles:   |  If using private certificates, this is the name and location of the private CA file.  Usually located in the Assets directory
 | fence.jwt_private_key:  | generate one if you want |
 |  fence.jwt_public_key: | generate one if you want  |
**Arborist** |  |CDIS [Documentation](https://github.com/uc-cdis/arborist#arborist)  |
 |  arborist.database: | Name of the arborist database, also username and password  |
**Image** | image.imagePullSecrets:  |  If you are using a private registry that requires authentication, you need to create a K8S secret that encodes access to that repo.  Put the name of that secret here or leave it blank.  [Reference](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)  |
**Ingress** |   | This defines how traffic from the internet comes into the K8S environment and connects to your reverse proxy and other services.  |
|  ingress.hosts.host: |  This is usually the host name of your URL |
|  ingress.hosts.host.paths.path.serviceName:| The name of the reverse proxy service.  (Debt, generate this from other settings...)
| ingress.tls.secretName: | You need to create a K8S secret that has the certificate files for doing TLS/SSL for your site.  See the [guide to SSL and Auth](SSL.md)
| ingress.hosts.secretName.hosts: | This is the host name of your site. (Debt - generate this automatically and remove from values file)
**ReverseProxy** | | This is the front door of your gen3 web site, it directs traffic to all other microservices, and even between them.
  | revproxy.crtFile:  |  Path to the requisit TLS file see [guide to SSL and Auth](SSL.md)
  | revproxy.keyFile:  |  Path to the requisit TLS file see [guide to SSL and Auth](SSL.md) |
  | revproxy.cacrtFile:|  Path to the requisit TLS file see [guide to SSL and Auth](SSL.md) |
**Peregrine** |   | [CDIS Documentation](https://github.com/uc-cdis/peregrine/blob/master/README.md)  |
  | peregrine.database:  |  Name of the peregrine database, also username and password |
  | peregrine.gdcapi_secret_key:  | A random string for seeding something in peregrine  |
  |  peregrine.hmac_key:  |  set to the same string as above?  (Debt - Find out what these are actually for) |
  | peregrine.schemas:   |  If you use a custom schema, this should be set to a file name that is a compress tar of the schema directory. |
  **Tube** |   | [CDIS Documentation](https://github.com/uc-cdis/tube/blob/master/README.md)  |
  |  tube.esrootcalocation: | When elasticsearch is created, it makes its own root CA key.   See [Elastic Setup](ELASTIC.md) |
   | tube.elasticusername:  | A username that can create and manage data in the elasticsearch instance.  |
  | tube.elasticpasswordb64:  | The password to said username, base64 encoded  |
  | tube.elastic.url: | The URL of the elasticsearch client node or service name in the K8S cluster
**Sheepdog** | |[CDIS Documentation](https://github.com/uc-cdis/sheepdog/blob/master/README.md) |
|- sheepdog.database:  (user, password, databasename)
| sheepdog.schemas:   (in case you have a custom schema)
**Indexd** | | [CDIS Documentation](https://github.com/uc-cdis/indexd/blob/master/README.md)
 | indexd.database: |  Name of the indexd database, also username and password
 | indexd.username: |   |
 | indexd.password: |   |
**Portal** (Windmill)  |   |  [CDIS Documentation](https://github.com/uc-cdis/data-portal/blob/master/README.md) |
  | portal.externalhostname: | (Debt - generate this automatically and remove from values file)
  | portal.gitops: | path to PNG logo file that shows up on the portal.
 | portal.gitopslogo: | path to another PNG logo file that shows up on the portal.
**Jupyter**   |   |
  |  jupyter.image:  |  Set this if you have a custom notebook, otherwise set it to the [CDIS image](https://quay.io/repository/occ_data/jupyternotebook?tag=1.7.2&tab=tags) at quay.io. |
**Spark**  |   |  [CDIS Documentation](https://github.com/uc-cdis/data-portal/blob/master/README.md)|
 | spark.spark_master: | URL of your spark cluster|
