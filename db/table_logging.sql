CREATE TABLE logging (
log_id int unsigned not null,
log_type varchar(15) binary not null,
log_action varchar(15) binary not null,
log_timestamp datetime not null,
log_user int unsigned not null,
log_username varchar(255) binary NOT NULL default '',
log_namespace int(5) not null default 0,
log_title varchar(255) binary NOT NULL default '',
log_comment varchar(255) binary NOT NULL default '',
log_params varchar(255) binary NOT NULL default '',
log_new_flag int unsigned not null default 0,
log_old_flag int unsigned not null default 0,
PRIMARY KEY log_id (log_id)
);

