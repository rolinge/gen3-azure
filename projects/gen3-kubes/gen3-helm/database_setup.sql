
#POSTGRES_PASSWORD will come from the Terraform Output

# Your Terraform Output will supply the values for these strings. Manually enter them inside the single quotes.

CREATE USER fence_gen3dev_user with  createdb login password '<Enter fence_database_user Password Here>';
CREATE USER arborist_gen3dev_user with  createdb login password '<Enter arbortist_database_user Password Here>';
CREATE USER peregrine_gen3dev_user with  createdb login password '<Enter peregrine_database_user Password Here>';
CREATE USER sheepdog_gen3dev_user with  createdb login password '<Enter sheepdog_database_user Password Here>';
CREATE USER indexd_gen3dev_user with  createdb login password '<Enter indexd_database_user Password Here>';


grant all on database fence_db to fence_gen3dev_user;
grant all on database arborist_db to arborist_gen3dev_user;
grant all on database indexd_db to indexd_gen3dev_user;
grant all on database metadata_db to sheepdog_gen3dev_user;
grant all on database metadata_db to peregrine_gen3dev_user;

\c arbortist_db
CREATE ESTENSION ltree;
