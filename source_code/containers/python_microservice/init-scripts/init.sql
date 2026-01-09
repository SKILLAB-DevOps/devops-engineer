create table if not exists users (
    id serial primary key,
    username varchar(255) not null,
    password varchar(255) not null,
    email varchar(255) not null,
    created_at timestamp not null default current_timestamp
);

insert into users (username, password, email) values ('admin', 'admin', 'admin@localhost'); 
insert into users (username, password, email) values ('user', 'user', 'user@localhost');
insert into users (username, password, email) values ('pentester', 'pentester', 'pentester@localhost');
insert into users (username, password, email) values ('hrmanager', 'hrmanager', 'hrmanager@localhost');
insert into users (username, password, email) values ('itmanager', 'itmanager', 'itmanager@localhost');
insert into users (username, password, email) values ('ceo', 'ceo', 'ceo@localhost');
insert into users (username, password, email) values ('cfo', 'cfo', 'cfo@localhost');
insert into users (username, password, email) values ('cto', 'cto', 'cto@localhost');
insert into users (username, password, email) values ('ciso', 'ciso', 'ciso@localhost');
insert into users (username, password, email) values ('ciso2', 'ciso2', 'ciso2@localhost');
