CREATE DATABASE metadata_gen3dev_db;
CREATE DATABASE fence_gen3dev_db;
CREATE DATABASE indexd_gen3dev_db;

CREATE USER fence_gen3dev_user;
ALTER USER fence_gen3dev_user WITH PASSWORD 'fence_gen3dev9876_pass';
ALTER USER fence_gen3dev_user WITH SUPERUSER;

CREATE USER peregrine_gen3dev_user;
ALTER USER peregrine_gen3dev_user WITH PASSWORD 'peregrine_gen3dev9876_pass';
ALTER USER peregrine_gen3dev_user WITH SUPERUSER;

CREATE USER sheepdog_gen3dev_user;
ALTER USER sheepdog_gen3dev_user WITH PASSWORD 'sheepdog_gen3dev9876_pass';
ALTER USER sheepdog_gen3dev_user WITH SUPERUSER;

CREATE USER indexd_gen3dev_user;
ALTER USER indexd_gen3dev_user WITH PASSWORD 'indexd_gen3dev9876_pass';
ALTER USER indexd_gen3dev_user WITH SUPERUSER;

CREATE USER arborist_gen3dev_user;
ALTER USER arborist_gen3dev_user WITH PASSWORD 'arborist_gen3dev9876_pass';
ALTER USER arborist_gen3dev_user WITH SUPERUSER;
