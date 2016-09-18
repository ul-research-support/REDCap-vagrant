-- ----------------------------------------- --
-- REDCap Installation SQL --
-- ----------------------------------------- --
USE `redcap`;
-- ----------------------------------------- --
CREATE TABLE `redcap_actions` (
`action_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`survey_id` int(10) DEFAULT NULL,
`action_trigger` enum('MANUAL','ENDOFSURVEY','SURVEYQUESTION') COLLATE utf8_unicode_ci DEFAULT NULL,
`action_response` enum('NONE','EMAIL_PRIMARY','EMAIL_SECONDARY','EMAIL_TERTIARY','STOPSURVEY','PROMPT') COLLATE utf8_unicode_ci DEFAULT NULL,
`custom_text` text COLLATE utf8_unicode_ci,
`recipient_id` int(10) DEFAULT NULL COMMENT 'FK user_information',
PRIMARY KEY (`action_id`),
UNIQUE KEY `survey_recipient_id` (`survey_id`,`recipient_id`),
KEY `project_id` (`project_id`),
KEY `recipient_id` (`recipient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_auth` (
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
`password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Hash of user''s password',
`password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique random salt for password',
`legacy_hash` int(1) NOT NULL DEFAULT '0' COMMENT 'Using older legacy hash for password storage?',
`temp_pwd` int(1) NOT NULL DEFAULT '0' COMMENT 'Flag to force user to re-enter password',
`password_question` int(10) DEFAULT NULL COMMENT 'PK of question',
`password_answer` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'MD5 hash of answer to password recovery question',
`password_question_reminder` datetime DEFAULT NULL COMMENT 'When to prompt user to set up security question',
`password_reset_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`username`),
UNIQUE KEY `password_reset_key` (`password_reset_key`),
KEY `password_question` (`password_question`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_auth_history` (
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
`password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`timestamp` datetime DEFAULT NULL,
KEY `username_password` (`username`,`password`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores last 5 passwords';

CREATE TABLE `redcap_auth_questions` (
`qid` int(10) NOT NULL AUTO_INCREMENT,
`question` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`qid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_config` (
`field_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`value` mediumtext COLLATE utf8_unicode_ci,
PRIMARY KEY (`field_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores global settings';

CREATE TABLE `redcap_crons` (
`cron_id` int(10) NOT NULL AUTO_INCREMENT,
`cron_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique name for each job',
`cron_description` text COLLATE utf8_unicode_ci,
`cron_enabled` enum('ENABLED','DISABLED') COLLATE utf8_unicode_ci DEFAULT 'ENABLED',
`cron_frequency` int(10) DEFAULT NULL COMMENT 'seconds',
`cron_max_run_time` int(10) DEFAULT NULL COMMENT 'max # seconds a cron should run',
`cron_instances_max` int(2) NOT NULL DEFAULT '1' COMMENT 'Number of instances that can run simultaneously',
`cron_instances_current` int(2) NOT NULL DEFAULT '0' COMMENT 'Current number of instances running',
`cron_last_run_start` datetime DEFAULT NULL,
`cron_last_run_end` datetime DEFAULT NULL,
`cron_times_failed` int(2) NOT NULL DEFAULT '0' COMMENT 'After X failures, set as Disabled',
`cron_external_url` text COLLATE utf8_unicode_ci COMMENT 'URL to call for custom jobs not defined by REDCap',
PRIMARY KEY (`cron_id`),
UNIQUE KEY `cron_name` (`cron_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='List of all jobs to be run by universal cron job';

CREATE TABLE `redcap_crons_history` (
`ch_id` int(10) NOT NULL AUTO_INCREMENT,
`cron_id` int(10) DEFAULT NULL,
`cron_run_start` datetime DEFAULT NULL,
`cron_run_end` datetime DEFAULT NULL,
`cron_run_status` enum('PROCESSING','COMPLETED','FAILED') COLLATE utf8_unicode_ci DEFAULT NULL,
`cron_info` text COLLATE utf8_unicode_ci COMMENT 'Any pertinent info that might be logged',
PRIMARY KEY (`ch_id`),
KEY `cron_id` (`cron_id`),
KEY `cron_run_end` (`cron_run_end`),
KEY `cron_run_start` (`cron_run_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='History of all jobs run by universal cron job';

CREATE TABLE `redcap_dashboard_ip_location_cache` (
`ip` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
`latitude` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`longitude` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`region` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_data` (
`project_id` int(10) NOT NULL DEFAULT '0',
`event_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`value` text COLLATE utf8_unicode_ci,
`instance` smallint(4) DEFAULT NULL,
KEY `event_id_instance` (`event_id`,`instance`),
KEY `proj_record_field` (`project_id`,`record`,`field_name`),
KEY `project_field` (`project_id`,`field_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_data_access_groups` (
`group_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`group_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`group_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_data_quality_resolutions` (
`res_id` int(10) NOT NULL AUTO_INCREMENT,
`status_id` int(10) DEFAULT NULL COMMENT 'FK from data_quality_status',
`ts` datetime DEFAULT NULL COMMENT 'Date/time added',
`user_id` int(10) DEFAULT NULL COMMENT 'Current user',
`response_requested` int(1) NOT NULL DEFAULT '0' COMMENT 'Is a response requested?',
`response` enum('DATA_MISSING','TYPOGRAPHICAL_ERROR','CONFIRMED_CORRECT','WRONG_SOURCE','OTHER') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Response category if user responded to query',
`comment` text COLLATE utf8_unicode_ci COMMENT 'Text for comment',
`current_query_status` enum('OPEN','CLOSED','VERIFIED','DEVERIFIED') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Current query status of thread',
`upload_doc_id` int(10) DEFAULT NULL COMMENT 'FK of uploaded document',
`field_comment_edited` int(1) NOT NULL DEFAULT '0' COMMENT 'Denote if field comment was edited',
PRIMARY KEY (`res_id`),
KEY `doc_id` (`upload_doc_id`),
KEY `status_id` (`status_id`),
KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_data_quality_rules` (
`rule_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`rule_order` int(3) DEFAULT '1',
`rule_name` text COLLATE utf8_unicode_ci,
`rule_logic` text COLLATE utf8_unicode_ci,
`real_time_execute` int(1) NOT NULL DEFAULT '0' COMMENT 'Run in real-time on data entry forms?',
PRIMARY KEY (`rule_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_data_quality_status` (
`status_id` int(10) NOT NULL AUTO_INCREMENT,
`rule_id` int(10) DEFAULT NULL COMMENT 'FK from data_quality_rules table',
`pd_rule_id` int(2) DEFAULT NULL COMMENT 'Name of pre-defined rules',
`non_rule` int(1) DEFAULT NULL COMMENT '1 for non-rule, else NULL',
`project_id` int(11) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Only used if field-level is required',
`instance` smallint(4) NOT NULL DEFAULT '1',
`status` int(2) DEFAULT NULL COMMENT 'Current status of discrepancy',
`exclude` int(1) NOT NULL DEFAULT '0' COMMENT 'Hide from results',
`query_status` enum('OPEN','CLOSED','VERIFIED','DEVERIFIED') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Status of data query',
`assigned_user_id` int(10) DEFAULT NULL COMMENT 'UI ID of user assigned to query',
PRIMARY KEY (`status_id`),
UNIQUE KEY `nonrule_proj_record_event_field` (`non_rule`,`project_id`,`record`,`event_id`,`field_name`,`instance`),
UNIQUE KEY `pd_rule_proj_record_event_field` (`pd_rule_id`,`record`,`event_id`,`field_name`,`project_id`,`instance`),
UNIQUE KEY `rule_record_event` (`rule_id`,`record`,`event_id`,`instance`),
KEY `assigned_user_id` (`assigned_user_id`),
KEY `event_id` (`event_id`),
KEY `pd_rule_proj_record_event` (`pd_rule_id`,`record`,`event_id`,`project_id`,`instance`),
KEY `project_query_status` (`project_id`,`query_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_log_view` (
`ml_id` int(10) NOT NULL AUTO_INCREMENT,
`time_viewed` datetime DEFAULT NULL COMMENT 'Time the data was displayed to the user',
`user_id` int(10) DEFAULT NULL COMMENT 'PK from user_information table',
`project_id` int(10) DEFAULT NULL,
`source_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'ID value from source system (e.g. MRN)',
PRIMARY KEY (`ml_id`),
KEY `project_id` (`project_id`),
KEY `source_id` (`source_id`),
KEY `time_viewed` (`time_viewed`),
KEY `user_project` (`user_id`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_log_view_data` (
`ml_id` int(10) DEFAULT NULL COMMENT 'PK from ddp_log_view table',
`source_field` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Field name from source system',
`source_timestamp` datetime DEFAULT NULL COMMENT 'Date of service from source system',
`md_id` int(10) DEFAULT NULL COMMENT 'PK from ddp_records_data table',
KEY `md_id` (`md_id`),
KEY `ml_id` (`ml_id`),
KEY `source_field` (`source_field`),
KEY `source_timestamp` (`source_timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_mapping` (
`map_id` int(10) NOT NULL AUTO_INCREMENT,
`external_source_field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique name of field mapped from external data source',
`is_record_identifier` int(1) DEFAULT NULL COMMENT '1=Yes, Null=No',
`project_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`temporal_field` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'REDCap date field',
`preselect` enum('MIN','MAX','FIRST','LAST','NEAR') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Preselect a source value for temporal fields only',
PRIMARY KEY (`map_id`),
UNIQUE KEY `project_field_event_source` (`project_id`,`event_id`,`field_name`,`external_source_field_name`),
UNIQUE KEY `project_identifier` (`project_id`,`is_record_identifier`),
KEY `event_id` (`event_id`),
KEY `external_source_field_name` (`external_source_field_name`),
KEY `field_name` (`field_name`),
KEY `temporal_field` (`temporal_field`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_preview_fields` (
`project_id` int(10) NOT NULL,
`field1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field4` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field5` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_records` (
`mr_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`updated_at` datetime DEFAULT NULL COMMENT 'Time of last data fetch',
`item_count` int(10) DEFAULT NULL COMMENT 'New item count (as of last viewing)',
`fetch_status` enum('QUEUED','FETCHING') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Current status of data fetch for this record',
`future_date_count` int(10) NOT NULL DEFAULT '0' COMMENT 'Count of datetime reference fields with values in the future',
PRIMARY KEY (`mr_id`),
UNIQUE KEY `project_record` (`project_id`,`record`),
KEY `project_id_fetch_status` (`fetch_status`,`project_id`),
KEY `project_updated_at` (`updated_at`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ddp_records_data` (
`md_id` int(10) NOT NULL AUTO_INCREMENT,
`map_id` int(10) NOT NULL COMMENT 'PK from ddp_mapping table',
`mr_id` int(10) DEFAULT NULL COMMENT 'PK from ddp_records table',
`source_timestamp` datetime DEFAULT NULL COMMENT 'Date of service from source system',
`source_value` text COLLATE utf8_unicode_ci COMMENT 'Encrypted data value from source system',
`adjudicated` int(1) NOT NULL DEFAULT '0' COMMENT 'Has source value been adjudicated?',
`exclude` int(1) NOT NULL DEFAULT '0' COMMENT 'Has source value been excluded?',
PRIMARY KEY (`md_id`),
KEY `map_id_mr_id_timestamp_value` (`map_id`,`mr_id`,`source_timestamp`,`source_value`(255)),
KEY `map_id_timestamp` (`map_id`,`source_timestamp`),
KEY `mr_id_adjudicated` (`mr_id`,`adjudicated`),
KEY `mr_id_exclude` (`mr_id`,`exclude`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Cached data values from web service';

CREATE TABLE `redcap_docs` (
`docs_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL DEFAULT '0',
`docs_date` date DEFAULT NULL,
`docs_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`docs_size` double DEFAULT NULL,
`docs_type` text COLLATE utf8_unicode_ci,
`docs_file` longblob,
`docs_comment` text COLLATE utf8_unicode_ci,
`docs_rights` text COLLATE utf8_unicode_ci,
`export_file` int(1) NOT NULL DEFAULT '0',
`temp` int(1) NOT NULL DEFAULT '0' COMMENT 'Is file only a temp file?',
PRIMARY KEY (`docs_id`),
KEY `docs_name` (`docs_name`),
KEY `project_id_comment` (`project_id`,`docs_comment`(128)),
KEY `project_id_export_file_temp` (`project_id`,`export_file`,`temp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_docs_to_edocs` (
`docs_id` int(11) NOT NULL COMMENT 'PK redcap_docs',
`doc_id` int(11) NOT NULL COMMENT 'PK redcap_edocs_metadata',
PRIMARY KEY (`docs_id`,`doc_id`),
KEY `doc_id` (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_edocs_metadata` (
`doc_id` int(10) NOT NULL AUTO_INCREMENT,
`stored_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'stored name',
`mime_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`doc_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`doc_size` int(10) DEFAULT NULL,
`file_extension` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
`gzipped` int(1) NOT NULL DEFAULT '0' COMMENT 'Is file gzip compressed?',
`project_id` int(10) DEFAULT NULL,
`stored_date` datetime DEFAULT NULL COMMENT 'stored date',
`delete_date` datetime DEFAULT NULL COMMENT 'date deleted',
`date_deleted_server` datetime DEFAULT NULL COMMENT 'When really deleted from server',
PRIMARY KEY (`doc_id`),
KEY `date_deleted` (`delete_date`,`date_deleted_server`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_esignatures` (
`esign_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`instance` smallint(4) NOT NULL DEFAULT '1',
`username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`timestamp` datetime DEFAULT NULL,
PRIMARY KEY (`esign_id`),
UNIQUE KEY `proj_rec_event_form_instance` (`project_id`,`record`,`event_id`,`form_name`,`instance`),
KEY `event_id` (`event_id`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_events_arms` (
`arm_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL DEFAULT '0',
`arm_num` int(2) NOT NULL DEFAULT '1',
`arm_name` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Arm 1',
PRIMARY KEY (`arm_id`),
UNIQUE KEY `proj_arm_num` (`project_id`,`arm_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_events_calendar` (
`cal_id` int(10) NOT NULL AUTO_INCREMENT,
`record` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`baseline_date` date DEFAULT NULL,
`group_id` int(10) DEFAULT NULL,
`event_date` date DEFAULT NULL,
`event_time` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'HH:MM',
`event_status` int(2) DEFAULT NULL COMMENT 'NULL=Ad Hoc, 0=Due Date, 1=Scheduled, 2=Confirmed, 3=Cancelled, 4=No Show',
`note_type` int(2) DEFAULT NULL,
`notes` text COLLATE utf8_unicode_ci,
`extra_notes` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`cal_id`),
KEY `event_id` (`event_id`),
KEY `group_id` (`group_id`),
KEY `project_date` (`project_id`,`event_date`),
KEY `project_record` (`project_id`,`record`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Calendar Data';

CREATE TABLE `redcap_events_forms` (
`event_id` int(10) NOT NULL DEFAULT '0',
`form_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
UNIQUE KEY `event_form` (`event_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_events_metadata` (
`event_id` int(10) NOT NULL AUTO_INCREMENT,
`arm_id` int(10) NOT NULL DEFAULT '0' COMMENT 'FK for events_arms',
`day_offset` float NOT NULL DEFAULT '0' COMMENT 'Days from Start Date',
`offset_min` float NOT NULL DEFAULT '0',
`offset_max` float NOT NULL DEFAULT '0',
`descrip` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Event 1' COMMENT 'Event Name',
`external_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`event_id`),
KEY `arm_dayoffset_descrip` (`arm_id`,`day_offset`,`descrip`),
KEY `day_offset` (`day_offset`),
KEY `descrip` (`descrip`),
KEY `external_id` (`external_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_events_repeat` (
`event_id` int(10) DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
UNIQUE KEY `event_id_form` (`event_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_external_links` (
`ext_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`link_order` int(5) NOT NULL DEFAULT '1',
`link_url` text COLLATE utf8_unicode_ci,
`link_label` text COLLATE utf8_unicode_ci,
`open_new_window` int(10) NOT NULL DEFAULT '0',
`link_type` enum('LINK','POST_AUTHKEY','REDCAP_PROJECT') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'LINK',
`user_access` enum('ALL','DAG','SELECTED') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'ALL',
`append_record_info` int(1) NOT NULL DEFAULT '0' COMMENT 'Append record and event to URL',
`append_pid` int(1) NOT NULL DEFAULT '0' COMMENT 'Append project_id to URL',
`link_to_project_id` int(10) DEFAULT NULL,
PRIMARY KEY (`ext_id`),
KEY `link_to_project_id` (`link_to_project_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_external_links_dags` (
`ext_id` int(11) NOT NULL AUTO_INCREMENT,
`group_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`ext_id`,`group_id`),
KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_external_links_exclude_projects` (
`ext_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`ext_id`,`project_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Projects to exclude for global external links';

CREATE TABLE `redcap_external_links_users` (
`ext_id` int(11) NOT NULL AUTO_INCREMENT,
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
PRIMARY KEY (`ext_id`,`username`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_folders` (
`folder_id` int(10) NOT NULL AUTO_INCREMENT,
`ui_id` int(10) DEFAULT NULL,
`name` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
`position` int(10) DEFAULT NULL,
`foreground` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`background` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`collapsed` tinyint(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`folder_id`),
UNIQUE KEY `ui_id_name_uniq` (`ui_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_folders_projects` (
`ui_id` int(10) DEFAULT NULL,
`project_id` int(10) DEFAULT NULL,
`folder_id` int(10) DEFAULT NULL,
UNIQUE KEY `ui_id_project_folder` (`ui_id`,`project_id`,`folder_id`),
KEY `folder_id` (`folder_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_history_size` (
`date` date NOT NULL DEFAULT '1000-01-01',
`size_db` float DEFAULT NULL COMMENT 'MB',
`size_files` float DEFAULT NULL COMMENT 'MB',
PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Space usage of REDCap database and uploaded files.';

CREATE TABLE `redcap_history_version` (
`date` date NOT NULL DEFAULT '1000-01-01',
`redcap_version` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='History of REDCap versions installed on this server.';

CREATE TABLE `redcap_instrument_zip` (
`iza_id` int(10) NOT NULL DEFAULT '0',
`instrument_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`upload_count` smallint(5) NOT NULL DEFAULT '1',
PRIMARY KEY (`iza_id`,`instrument_id`),
KEY `instrument_id` (`instrument_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_instrument_zip_authors` (
`iza_id` int(10) NOT NULL AUTO_INCREMENT,
`author_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`iza_id`),
UNIQUE KEY `author_name` (`author_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_instrument_zip_origins` (
`server_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`upload_count` smallint(5) NOT NULL DEFAULT '1',
PRIMARY KEY (`server_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ip_banned` (
`ip` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
`time_of_ban` timestamp NULL DEFAULT NULL,
PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_ip_cache` (
`ip_hash` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
`timestamp` timestamp NULL DEFAULT NULL,
KEY `ip_hash` (`ip_hash`),
KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_library_map` (
`project_id` int(10) NOT NULL DEFAULT '0',
`form_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`type` int(11) NOT NULL DEFAULT '0' COMMENT '1 = Downloaded; 2 = Uploaded',
`library_id` int(10) NOT NULL DEFAULT '0',
`upload_timestamp` datetime DEFAULT NULL,
`acknowledgement` text COLLATE utf8_unicode_ci,
`acknowledgement_cache` datetime DEFAULT NULL,
`promis_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'PROMIS instrument key',
`scoring_type` enum('EACH_ITEM','END_ONLY') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'If has scoring, what type?',
PRIMARY KEY (`project_id`,`form_name`,`type`,`library_id`),
KEY `form_name` (`form_name`),
KEY `library_id` (`library_id`),
KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_locking_data` (
`ld_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`instance` smallint(4) NOT NULL DEFAULT '1',
`username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`timestamp` datetime DEFAULT NULL,
PRIMARY KEY (`ld_id`),
UNIQUE KEY `proj_rec_event_form_instance` (`project_id`,`record`,`event_id`,`form_name`,`instance`),
KEY `event_id` (`event_id`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_locking_labels` (
`ll_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(11) DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`label` text COLLATE utf8_unicode_ci,
`display` int(1) NOT NULL DEFAULT '1',
`display_esignature` int(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`ll_id`),
UNIQUE KEY `project_form` (`project_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_log_event` (
`log_event_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL DEFAULT '0',
`ts` bigint(14) DEFAULT NULL,
`user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`ip` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`page` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`event` enum('UPDATE','INSERT','DELETE','SELECT','ERROR','LOGIN','LOGOUT','OTHER','DATA_EXPORT','DOC_UPLOAD','DOC_DELETE','MANAGE','LOCK_RECORD','ESIGNATURE') COLLATE utf8_unicode_ci DEFAULT NULL,
`object_type` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
`sql_log` mediumtext COLLATE utf8_unicode_ci,
`pk` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`data_values` text COLLATE utf8_unicode_ci,
`description` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`legacy` int(1) NOT NULL DEFAULT '0',
`change_reason` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`log_event_id`),
KEY `description` (`description`),
KEY `event_project` (`event`,`project_id`),
KEY `object_type` (`object_type`),
KEY `pk` (`pk`),
KEY `ts` (`ts`),
KEY `user` (`user`),
KEY `user_project` (`project_id`,`user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_log_view` (
`log_view_id` int(11) NOT NULL AUTO_INCREMENT,
`ts` timestamp NULL DEFAULT NULL,
`user` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`event` enum('LOGIN_SUCCESS','LOGIN_FAIL','LOGOUT','PAGE_VIEW') COLLATE utf8_unicode_ci DEFAULT NULL,
`ip` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`browser_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`browser_version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`full_url` text COLLATE utf8_unicode_ci,
`page` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`record` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`miscellaneous` text COLLATE utf8_unicode_ci,
`session_id` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`log_view_id`),
KEY `browser_name` (`browser_name`),
KEY `browser_version` (`browser_version`),
KEY `event` (`event`),
KEY `ip` (`ip`),
KEY `page` (`page`),
KEY `project_event_record` (`project_id`,`event_id`,`record`),
KEY `session_id` (`session_id`),
KEY `ts` (`ts`),
KEY `user_project` (`user`,`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_log_view_requests` (
`lvr_id` int(10) NOT NULL AUTO_INCREMENT,
`log_view_id` int(10) DEFAULT NULL COMMENT 'FK from redcap_log_view',
`mysql_process_id` int(10) DEFAULT NULL COMMENT 'Process ID for MySQL',
`php_process_id` int(10) DEFAULT NULL COMMENT 'Process ID for PHP',
`script_execution_time` float DEFAULT NULL COMMENT 'Total PHP script execution time (seconds)',
`is_ajax` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is request an AJAX request?',
PRIMARY KEY (`lvr_id`),
UNIQUE KEY `log_view_id` (`log_view_id`),
UNIQUE KEY `log_view_id_time` (`log_view_id`,`script_execution_time`),
KEY `mysql_process_id` (`mysql_process_id`),
KEY `php_process_id` (`php_process_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_metadata` (
`project_id` int(10) NOT NULL DEFAULT '0',
`field_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`field_phi` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_menu_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_order` float DEFAULT NULL,
`field_units` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_preceding_header` mediumtext COLLATE utf8_unicode_ci,
`element_type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_label` mediumtext COLLATE utf8_unicode_ci,
`element_enum` mediumtext COLLATE utf8_unicode_ci,
`element_note` mediumtext COLLATE utf8_unicode_ci,
`element_validation_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_min` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_max` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_checktype` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`branching_logic` text COLLATE utf8_unicode_ci,
`field_req` int(1) NOT NULL DEFAULT '0',
`edoc_id` int(10) DEFAULT NULL COMMENT 'image/file attachment',
`edoc_display_img` int(1) NOT NULL DEFAULT '0',
`custom_alignment` enum('LH','LV','RH','RV') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'RV = NULL = default',
`stop_actions` text COLLATE utf8_unicode_ci,
`question_num` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`grid_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique name of grid group',
`grid_rank` int(1) NOT NULL DEFAULT '0',
`misc` mediumtext COLLATE utf8_unicode_ci COMMENT 'Miscellaneous field attributes',
`video_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`video_display_inline` tinyint(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`project_id`,`field_name`),
KEY `edoc_id` (`edoc_id`),
KEY `field_name` (`field_name`),
KEY `project_id_fieldorder` (`project_id`,`field_order`),
KEY `project_id_form` (`project_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_metadata_archive` (
`project_id` int(10) NOT NULL DEFAULT '0',
`field_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`field_phi` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_menu_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_order` float DEFAULT NULL,
`field_units` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_preceding_header` mediumtext COLLATE utf8_unicode_ci,
`element_type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_label` mediumtext COLLATE utf8_unicode_ci,
`element_enum` mediumtext COLLATE utf8_unicode_ci,
`element_note` mediumtext COLLATE utf8_unicode_ci,
`element_validation_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_min` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_max` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_checktype` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`branching_logic` text COLLATE utf8_unicode_ci,
`field_req` int(1) NOT NULL DEFAULT '0',
`edoc_id` int(10) DEFAULT NULL COMMENT 'image/file attachment',
`edoc_display_img` int(1) NOT NULL DEFAULT '0',
`custom_alignment` enum('LH','LV','RH','RV') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'RV = NULL = default',
`stop_actions` text COLLATE utf8_unicode_ci,
`question_num` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`grid_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique name of grid group',
`grid_rank` int(1) NOT NULL DEFAULT '0',
`misc` mediumtext COLLATE utf8_unicode_ci COMMENT 'Miscellaneous field attributes',
`video_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`video_display_inline` tinyint(1) NOT NULL DEFAULT '0',
`pr_id` int(10) DEFAULT NULL,
UNIQUE KEY `project_field_prid` (`project_id`,`field_name`,`pr_id`),
KEY `edoc_id` (`edoc_id`),
KEY `field_name` (`field_name`),
KEY `pr_id` (`pr_id`),
KEY `project_id_form` (`project_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_metadata_prod_revisions` (
`pr_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL DEFAULT '0',
`ui_id_requester` int(10) DEFAULT NULL,
`ui_id_approver` int(10) DEFAULT NULL,
`ts_req_approval` datetime DEFAULT NULL,
`ts_approved` datetime DEFAULT NULL,
PRIMARY KEY (`pr_id`),
KEY `project_approved` (`project_id`,`ts_approved`),
KEY `project_user` (`project_id`,`ui_id_requester`),
KEY `ui_id_approver` (`ui_id_approver`),
KEY `ui_id_requester` (`ui_id_requester`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_metadata_temp` (
`project_id` int(10) NOT NULL DEFAULT '0',
`field_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`field_phi` varchar(5) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`form_menu_description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_order` float DEFAULT NULL,
`field_units` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_preceding_header` mediumtext COLLATE utf8_unicode_ci,
`element_type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_label` mediumtext COLLATE utf8_unicode_ci,
`element_enum` mediumtext COLLATE utf8_unicode_ci,
`element_note` mediumtext COLLATE utf8_unicode_ci,
`element_validation_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_min` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_max` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`element_validation_checktype` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`branching_logic` text COLLATE utf8_unicode_ci,
`field_req` int(1) NOT NULL DEFAULT '0',
`edoc_id` int(10) DEFAULT NULL COMMENT 'image/file attachment',
`edoc_display_img` int(1) NOT NULL DEFAULT '0',
`custom_alignment` enum('LH','LV','RH','RV') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'RV = NULL = default',
`stop_actions` text COLLATE utf8_unicode_ci,
`question_num` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`grid_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Unique name of grid group',
`grid_rank` int(1) NOT NULL DEFAULT '0',
`misc` mediumtext COLLATE utf8_unicode_ci COMMENT 'Miscellaneous field attributes',
`video_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`video_display_inline` tinyint(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`project_id`,`field_name`),
KEY `edoc_id` (`edoc_id`),
KEY `field_name` (`field_name`),
KEY `project_id_form` (`project_id`,`form_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_mobile_app_files` (
`af_id` int(10) NOT NULL AUTO_INCREMENT,
`doc_id` int(10) NOT NULL,
`type` enum('ESCAPE_HATCH','LOGGING') COLLATE utf8_unicode_ci DEFAULT NULL,
`user_id` int(10) DEFAULT NULL,
PRIMARY KEY (`af_id`),
KEY `doc_id` (`doc_id`),
KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_mobile_app_log` (
`mal_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`log_event_id` int(10) DEFAULT NULL,
`event` enum('INIT_PROJECT','INIT_DOWNLOAD_DATA','INIT_DOWNLOAD_DATA_PARTIAL','REINIT_PROJECT','REINIT_DOWNLOAD_DATA','REINIT_DOWNLOAD_DATA_PARTIAL','SYNC_DATA') COLLATE utf8_unicode_ci DEFAULT NULL,
`details` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`mal_id`),
KEY `log_event_id` (`log_event_id`),
KEY `project_id_event` (`project_id`,`event`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_new_record_cache` (
`project_id` int(10) NOT NULL DEFAULT '0',
`event_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`creation_time` datetime DEFAULT NULL,
UNIQUE KEY `proj_record_event` (`project_id`,`record`,`event_id`),
KEY `creation_time` (`creation_time`),
KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Save new record names to prevent record duplication';

CREATE TABLE `redcap_page_hits` (
`date` date NOT NULL,
`page_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`page_hits` float NOT NULL DEFAULT '1',
UNIQUE KEY `date` (`date`,`page_name`),
KEY `page_name` (`page_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_project_checklist` (
`list_id` int(11) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`list_id`),
UNIQUE KEY `project_name` (`project_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_projects` (
`project_id` int(10) NOT NULL AUTO_INCREMENT,
`project_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`app_title` text COLLATE utf8_unicode_ci,
`status` int(1) NOT NULL DEFAULT '0',
`creation_time` datetime DEFAULT NULL,
`production_time` datetime DEFAULT NULL,
`inactive_time` datetime DEFAULT NULL,
`created_by` int(10) DEFAULT NULL COMMENT 'FK from User Info',
`draft_mode` int(1) NOT NULL DEFAULT '0',
`surveys_enabled` int(1) NOT NULL DEFAULT '0' COMMENT '0 = forms only, 1 = survey+forms, 2 = single survey only',
`repeatforms` int(1) NOT NULL DEFAULT '0',
`scheduling` int(1) NOT NULL DEFAULT '0',
`purpose` int(2) DEFAULT NULL,
`purpose_other` text COLLATE utf8_unicode_ci,
`show_which_records` int(1) NOT NULL DEFAULT '0',
`__SALT__` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Alphanumeric hash unique to each project',
`count_project` int(1) NOT NULL DEFAULT '1',
`investigators` text COLLATE utf8_unicode_ci,
`project_note` mediumtext COLLATE utf8_unicode_ci,
`online_offline` int(1) NOT NULL DEFAULT '1',
`auth_meth` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`double_data_entry` int(1) NOT NULL DEFAULT '0',
`project_language` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'English',
`project_encoding` enum('japanese_sjis','chinese_utf8') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Encoding to be used for various exported files',
`is_child_of` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`date_shift_max` int(10) NOT NULL DEFAULT '364',
`institution` text COLLATE utf8_unicode_ci,
`site_org_type` text COLLATE utf8_unicode_ci,
`grant_cite` text COLLATE utf8_unicode_ci,
`project_contact_name` text COLLATE utf8_unicode_ci,
`project_contact_email` text COLLATE utf8_unicode_ci,
`headerlogo` text COLLATE utf8_unicode_ci,
`auto_inc_set` int(1) NOT NULL DEFAULT '0',
`custom_data_entry_note` text COLLATE utf8_unicode_ci,
`custom_index_page_note` text COLLATE utf8_unicode_ci,
`order_id_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`custom_reports` mediumtext COLLATE utf8_unicode_ci COMMENT 'Legacy report builder',
`report_builder` mediumtext COLLATE utf8_unicode_ci,
`disable_data_entry` int(1) NOT NULL DEFAULT '0',
`google_translate_default` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
`require_change_reason` int(1) NOT NULL DEFAULT '0',
`dts_enabled` int(1) NOT NULL DEFAULT '0',
`project_pi_firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_mi` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_alias` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_pub_exclude` int(1) DEFAULT NULL,
`project_pub_matching_institution` text COLLATE utf8_unicode_ci,
`project_irb_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_grant_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`history_widget_enabled` int(1) NOT NULL DEFAULT '1',
`secondary_pk` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'field_name of seconary identifier',
`custom_record_label` text COLLATE utf8_unicode_ci,
`display_project_logo_institution` int(1) NOT NULL DEFAULT '1',
`imported_from_rs` int(1) NOT NULL DEFAULT '0' COMMENT 'If imported from REDCap Survey',
`display_today_now_button` int(1) NOT NULL DEFAULT '1',
`auto_variable_naming` int(1) NOT NULL DEFAULT '0',
`randomization` int(1) NOT NULL DEFAULT '0',
`enable_participant_identifiers` int(1) NOT NULL DEFAULT '0',
`survey_email_participant_field` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Field name that stores participant email',
`survey_phone_participant_field` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Field name that stores participant phone number',
`data_entry_trigger_url` text COLLATE utf8_unicode_ci COMMENT 'URL for sending Post request when a record is created or modified',
`template_id` int(10) DEFAULT NULL COMMENT 'If created from a project template, the project_id of the template',
`date_deleted` datetime DEFAULT NULL COMMENT 'Time that project was flagged for deletion',
`data_resolution_enabled` int(1) NOT NULL DEFAULT '1' COMMENT '0=Disabled, 1=Field comment log, 2=Data Quality resolution workflow',
`field_comment_edit_delete` int(1) NOT NULL DEFAULT '1' COMMENT 'Allow users to edit or delete Field Comments',
`realtime_webservice_enabled` int(1) NOT NULL DEFAULT '0' COMMENT 'Is real-time web service enabled for external data import?',
`realtime_webservice_offset_days` float NOT NULL DEFAULT '1' COMMENT 'Default value of days offset',
`realtime_webservice_offset_plusminus` enum('+','-','+-') COLLATE utf8_unicode_ci NOT NULL DEFAULT '+-' COMMENT 'Default value of plus-minus range for days offset',
`last_logged_event` datetime DEFAULT NULL,
`survey_queue_custom_text` text COLLATE utf8_unicode_ci,
`survey_auth_enabled` int(1) NOT NULL DEFAULT '0',
`survey_auth_field1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`survey_auth_event_id1` int(10) DEFAULT NULL,
`survey_auth_field2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`survey_auth_event_id2` int(10) DEFAULT NULL,
`survey_auth_field3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`survey_auth_event_id3` int(10) DEFAULT NULL,
`survey_auth_min_fields` enum('1','2','3') COLLATE utf8_unicode_ci DEFAULT NULL,
`survey_auth_apply_all_surveys` int(1) NOT NULL DEFAULT '1',
`survey_auth_custom_message` text COLLATE utf8_unicode_ci,
`survey_auth_fail_limit` int(2) DEFAULT NULL,
`survey_auth_fail_window` int(3) DEFAULT NULL,
`twilio_enabled` int(1) NOT NULL DEFAULT '0',
`twilio_account_sid` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
`twilio_auth_token` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
`twilio_from_number` bigint(16) DEFAULT NULL,
`twilio_voice_language` varchar(5) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'en',
`twilio_option_voice_initiate` tinyint(1) NOT NULL DEFAULT '0',
`twilio_option_sms_initiate` tinyint(1) NOT NULL DEFAULT '0',
`twilio_option_sms_invite_make_call` tinyint(1) NOT NULL DEFAULT '0',
`twilio_option_sms_invite_receive_call` tinyint(1) NOT NULL DEFAULT '0',
`twilio_option_sms_invite_web` tinyint(1) NOT NULL DEFAULT '0',
`twilio_default_delivery_preference` enum('EMAIL','VOICE_INITIATE','SMS_INITIATE','SMS_INVITE_MAKE_CALL','SMS_INVITE_RECEIVE_CALL','SMS_INVITE_WEB') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'EMAIL',
`twilio_request_inspector_checked` datetime DEFAULT NULL,
`twilio_request_inspector_enabled` int(1) NOT NULL DEFAULT '1',
`twilio_append_response_instructions` int(1) NOT NULL DEFAULT '1',
`twilio_multiple_sms_behavior` enum('OVERWRITE','CHOICE','FIRST') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'CHOICE',
`two_factor_exempt_project` tinyint(1) NOT NULL DEFAULT '0',
`two_factor_force_project` tinyint(1) NOT NULL DEFAULT '0',
`disable_autocalcs` tinyint(1) NOT NULL DEFAULT '0',
`custom_public_survey_links` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`project_id`),
UNIQUE KEY `project_name` (`project_name`),
UNIQUE KEY `twilio_from_number` (`twilio_from_number`),
KEY `created_by` (`created_by`),
KEY `last_logged_event` (`last_logged_event`),
KEY `project_note` (`project_note`(255)),
KEY `survey_auth_event_id1` (`survey_auth_event_id1`),
KEY `survey_auth_event_id2` (`survey_auth_event_id2`),
KEY `survey_auth_event_id3` (`survey_auth_event_id3`),
KEY `template_id` (`template_id`),
KEY `twilio_account_sid` (`twilio_account_sid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores project-level values';

CREATE TABLE `redcap_projects_external` (
`project_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Brief user-defined project identifier unique within custom_type',
`custom_type` varchar(32) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Brief user-defined name for the resource/category/bucket under which the project falls',
`app_title` text COLLATE utf8_unicode_ci,
`creation_time` datetime DEFAULT NULL,
`project_pi_firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_mi` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_alias` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_pi_pub_exclude` int(1) DEFAULT NULL,
`project_pub_matching_institution` text COLLATE utf8_unicode_ci NOT NULL,
PRIMARY KEY (`project_id`,`custom_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_projects_templates` (
`project_id` int(10) NOT NULL DEFAULT '0',
`title` text COLLATE utf8_unicode_ci,
`description` text COLLATE utf8_unicode_ci,
`enabled` int(1) NOT NULL DEFAULT '0' COMMENT 'If enabled, template is visible to users in list.',
PRIMARY KEY (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Info about which projects are used as templates';

CREATE TABLE `redcap_pub_articles` (
`article_id` int(10) NOT NULL AUTO_INCREMENT,
`pubsrc_id` int(10) NOT NULL,
`pub_id` varchar(16) COLLATE utf8_unicode_ci NOT NULL COMMENT 'The publication source''s ID for the article (e.g., a PMID in the case of PubMed)',
`title` text COLLATE utf8_unicode_ci,
`volume` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
`issue` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
`pages` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
`journal` text COLLATE utf8_unicode_ci,
`journal_abbrev` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
`pub_date` date DEFAULT NULL,
`epub_date` date DEFAULT NULL,
PRIMARY KEY (`article_id`),
UNIQUE KEY `pubsrc_id` (`pubsrc_id`,`pub_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Articles pulled from a publication source (e.g., PubMed)';

CREATE TABLE `redcap_pub_authors` (
`author_id` int(10) NOT NULL AUTO_INCREMENT,
`article_id` int(10) DEFAULT NULL,
`author` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`author_id`),
KEY `article_id` (`article_id`),
KEY `author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_pub_matches` (
`match_id` int(11) NOT NULL AUTO_INCREMENT,
`article_id` int(11) NOT NULL,
`project_id` int(11) DEFAULT NULL,
`external_project_id` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'FK 1/2 referencing redcap_projects_external (not explicitly defined as FK to allow redcap_projects_external to be blown away)',
`external_custom_type` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'FK 2/2 referencing redcap_projects_external (not explicitly defined as FK to allow redcap_projects_external to be blown away)',
`search_term` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
`matched` int(1) DEFAULT NULL,
`matched_time` datetime DEFAULT NULL,
`email_count` int(11) NOT NULL DEFAULT '0',
`email_time` datetime DEFAULT NULL,
`unique_hash` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
PRIMARY KEY (`match_id`),
UNIQUE KEY `unique_hash` (`unique_hash`),
KEY `article_id` (`article_id`),
KEY `external_custom_type` (`external_custom_type`),
KEY `external_project_id` (`external_project_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_pub_mesh_terms` (
`mesh_id` int(10) NOT NULL AUTO_INCREMENT,
`article_id` int(10) DEFAULT NULL,
`mesh_term` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`mesh_id`),
KEY `article_id` (`article_id`),
KEY `mesh_term` (`mesh_term`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_pub_sources` (
`pubsrc_id` int(11) NOT NULL,
`pubsrc_name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
`pubsrc_last_crawl_time` datetime DEFAULT NULL,
PRIMARY KEY (`pubsrc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='The different places where we grab publications from';

CREATE TABLE `redcap_randomization` (
`rid` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`stratified` int(1) NOT NULL DEFAULT '1' COMMENT '1=Stratified, 0=Block',
`group_by` enum('DAG','FIELD') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Randomize by group?',
`target_field` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`target_event` int(10) DEFAULT NULL,
`source_field1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event1` int(10) DEFAULT NULL,
`source_field2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event2` int(10) DEFAULT NULL,
`source_field3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event3` int(10) DEFAULT NULL,
`source_field4` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event4` int(10) DEFAULT NULL,
`source_field5` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event5` int(10) DEFAULT NULL,
`source_field6` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event6` int(10) DEFAULT NULL,
`source_field7` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event7` int(10) DEFAULT NULL,
`source_field8` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event8` int(10) DEFAULT NULL,
`source_field9` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event9` int(10) DEFAULT NULL,
`source_field10` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event10` int(10) DEFAULT NULL,
`source_field11` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event11` int(10) DEFAULT NULL,
`source_field12` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event12` int(10) DEFAULT NULL,
`source_field13` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event13` int(10) DEFAULT NULL,
`source_field14` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event14` int(10) DEFAULT NULL,
`source_field15` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`source_event15` int(10) DEFAULT NULL,
PRIMARY KEY (`rid`),
UNIQUE KEY `project_id` (`project_id`),
KEY `source_event1` (`source_event1`),
KEY `source_event10` (`source_event10`),
KEY `source_event11` (`source_event11`),
KEY `source_event12` (`source_event12`),
KEY `source_event13` (`source_event13`),
KEY `source_event14` (`source_event14`),
KEY `source_event15` (`source_event15`),
KEY `source_event2` (`source_event2`),
KEY `source_event3` (`source_event3`),
KEY `source_event4` (`source_event4`),
KEY `source_event5` (`source_event5`),
KEY `source_event6` (`source_event6`),
KEY `source_event7` (`source_event7`),
KEY `source_event8` (`source_event8`),
KEY `source_event9` (`source_event9`),
KEY `target_event` (`target_event`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_randomization_allocation` (
`aid` int(10) NOT NULL AUTO_INCREMENT,
`rid` int(10) NOT NULL DEFAULT '0',
`project_status` int(1) NOT NULL DEFAULT '0' COMMENT 'Used in dev or prod status',
`is_used_by` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Used by a record?',
`group_id` int(10) DEFAULT NULL COMMENT 'DAG',
`target_field` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field4` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field5` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field6` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field7` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field8` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field9` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field10` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field11` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field12` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field13` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field14` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
`source_field15` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Data value',
PRIMARY KEY (`aid`),
UNIQUE KEY `rid_status_usedby` (`rid`,`project_status`,`is_used_by`),
KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports` (
`report_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) NOT NULL,
`title` text COLLATE utf8_unicode_ci,
`report_order` int(3) DEFAULT NULL,
`user_access` enum('ALL','SELECTED') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'ALL',
`output_dags` int(1) NOT NULL DEFAULT '0',
`output_survey_fields` int(1) NOT NULL DEFAULT '0',
`orderby_field1` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`orderby_sort1` enum('ASC','DESC') COLLATE utf8_unicode_ci DEFAULT NULL,
`orderby_field2` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`orderby_sort2` enum('ASC','DESC') COLLATE utf8_unicode_ci DEFAULT NULL,
`orderby_field3` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`orderby_sort3` enum('ASC','DESC') COLLATE utf8_unicode_ci DEFAULT NULL,
`advanced_logic` text COLLATE utf8_unicode_ci,
`filter_type` enum('RECORD','EVENT') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'EVENT',
`dynamic_filter1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`dynamic_filter2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`dynamic_filter3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`report_id`),
UNIQUE KEY `project_report_order` (`project_id`,`report_order`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_access_dags` (
`report_id` int(10) NOT NULL AUTO_INCREMENT,
`group_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`report_id`,`group_id`),
KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_access_roles` (
`report_id` int(10) NOT NULL DEFAULT '0',
`role_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`report_id`,`role_id`),
KEY `role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_access_users` (
`report_id` int(10) NOT NULL AUTO_INCREMENT,
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
PRIMARY KEY (`report_id`,`username`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_fields` (
`report_id` int(10) DEFAULT NULL,
`field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_order` int(3) DEFAULT NULL,
`limiter_group_operator` enum('AND','OR') COLLATE utf8_unicode_ci DEFAULT NULL,
`limiter_event_id` int(10) DEFAULT NULL,
`limiter_operator` enum('E','NE','GT','GTE','LT','LTE','CHECKED','UNCHECKED','CONTAINS','NOT_CONTAIN','STARTS_WITH','ENDS_WITH') COLLATE utf8_unicode_ci DEFAULT NULL,
`limiter_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
UNIQUE KEY `report_id_field_name_order` (`report_id`,`field_name`,`field_order`),
KEY `field_name` (`field_name`),
KEY `limiter_event_id` (`limiter_event_id`),
KEY `report_id_field_order` (`report_id`,`field_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_filter_dags` (
`report_id` int(10) NOT NULL AUTO_INCREMENT,
`group_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`report_id`,`group_id`),
KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_reports_filter_events` (
`report_id` int(10) NOT NULL AUTO_INCREMENT,
`event_id` int(10) NOT NULL DEFAULT '0',
PRIMARY KEY (`report_id`,`event_id`),
KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_sendit_docs` (
`document_id` int(11) NOT NULL AUTO_INCREMENT,
`doc_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`doc_orig_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`doc_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`doc_size` int(11) DEFAULT NULL,
`send_confirmation` int(1) NOT NULL DEFAULT '0',
`expire_date` datetime DEFAULT NULL,
`username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`location` int(1) NOT NULL DEFAULT '0' COMMENT '1 = Home page; 2 = File Repository; 3 = Form',
`docs_id` int(11) NOT NULL DEFAULT '0',
`date_added` datetime DEFAULT NULL,
`date_deleted` datetime DEFAULT NULL COMMENT 'When really deleted from server (only applicable for location=1)',
PRIMARY KEY (`document_id`),
KEY `date_added` (`date_added`),
KEY `docs_id_location` (`location`,`docs_id`),
KEY `expire_location_deleted` (`expire_date`,`location`,`date_deleted`),
KEY `user_id` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_sendit_recipients` (
`recipient_id` int(11) NOT NULL AUTO_INCREMENT,
`email_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`sent_confirmation` int(1) NOT NULL DEFAULT '0',
`download_date` datetime DEFAULT NULL,
`download_count` int(11) NOT NULL DEFAULT '0',
`document_id` int(11) NOT NULL DEFAULT '0' COMMENT 'FK from redcap_sendit_docs',
`guid` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`pwd` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`recipient_id`),
KEY `document_id` (`document_id`),
KEY `email_address` (`email_address`),
KEY `guid` (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_sessions` (
`session_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
`session_data` mediumtext COLLATE utf8_unicode_ci,
`session_expiration` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Stores user authentication session data';

CREATE TABLE `redcap_surveys` (
`survey_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`form_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'NULL = assume first form',
`title` text COLLATE utf8_unicode_ci COMMENT 'Survey title',
`instructions` text COLLATE utf8_unicode_ci COMMENT 'Survey instructions',
`acknowledgement` text COLLATE utf8_unicode_ci COMMENT 'Survey acknowledgement',
`question_by_section` int(1) NOT NULL DEFAULT '0' COMMENT '0 = one-page survey',
`display_page_number` int(1) NOT NULL DEFAULT '1',
`question_auto_numbering` int(1) NOT NULL DEFAULT '1',
`survey_enabled` int(1) NOT NULL DEFAULT '1',
`save_and_return` int(1) NOT NULL DEFAULT '0',
`logo` int(10) DEFAULT NULL COMMENT 'FK for redcap_edocs_metadata',
`hide_title` int(1) NOT NULL DEFAULT '0',
`view_results` int(1) NOT NULL DEFAULT '0',
`min_responses_view_results` int(5) NOT NULL DEFAULT '10',
`check_diversity_view_results` int(1) NOT NULL DEFAULT '0',
`end_survey_redirect_url` text COLLATE utf8_unicode_ci COMMENT 'URL to redirect to after completing survey',
`survey_expiration` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Timestamp when survey expires',
`promis_skip_question` int(1) NOT NULL DEFAULT '0' COMMENT 'Allow participants to skip questions on PROMIS CATs',
`survey_auth_enabled_single` int(1) NOT NULL DEFAULT '0' COMMENT 'Enable Survey Login for this single survey?',
`edit_completed_response` int(1) NOT NULL DEFAULT '0' COMMENT 'Allow respondents to return and edit a completed response?',
`hide_back_button` tinyint(1) NOT NULL DEFAULT '0',
`show_required_field_text` tinyint(1) NOT NULL DEFAULT '1',
`confirmation_email_subject` text COLLATE utf8_unicode_ci,
`confirmation_email_content` text COLLATE utf8_unicode_ci,
`confirmation_email_from` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`confirmation_email_attachment` int(10) DEFAULT NULL COMMENT 'FK for redcap_edocs_metadata',
`text_to_speech` int(1) NOT NULL DEFAULT '0',
`text_to_speech_language` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'en',
`end_survey_redirect_next_survey` tinyint(1) NOT NULL DEFAULT '0',
`theme` int(10) DEFAULT NULL,
`text_size` tinyint(2) DEFAULT NULL,
`font_family` tinyint(2) DEFAULT NULL,
`theme_text_buttons` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_page` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_title` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_title` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_sectionheader` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_sectionheader` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_question` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_question` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`survey_id`),
UNIQUE KEY `logo` (`logo`),
UNIQUE KEY `project_form` (`project_id`,`form_name`),
KEY `confirmation_email_attachment` (`confirmation_email_attachment`),
KEY `survey_expiration_enabled` (`survey_expiration`,`survey_enabled`),
KEY `theme` (`theme`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Table for survey data';

CREATE TABLE `redcap_surveys_emails` (
`email_id` int(10) NOT NULL AUTO_INCREMENT,
`survey_id` int(10) DEFAULT NULL,
`email_subject` text COLLATE utf8_unicode_ci,
`email_content` text COLLATE utf8_unicode_ci,
`email_sender` int(10) DEFAULT NULL COMMENT 'FK ui_id from redcap_user_information',
`email_account` enum('1','2','3') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Sender''s account (1=Primary, 2=Secondary, 3=Tertiary)',
`email_static` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Sender''s static email address (only for scheduled invitations)',
`email_sent` datetime DEFAULT NULL COMMENT 'Null=Not sent yet (scheduled)',
`delivery_type` enum('PARTICIPANT_PREF','EMAIL','VOICE_INITIATE','SMS_INITIATE','SMS_INVITE_MAKE_CALL','SMS_INVITE_RECEIVE_CALL','SMS_INVITE_WEB') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'EMAIL',
PRIMARY KEY (`email_id`),
KEY `email_sender` (`email_sender`),
KEY `email_sent` (`email_sent`),
KEY `survey_id_email_sent` (`survey_id`,`email_sent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Track emails sent out';

CREATE TABLE `redcap_surveys_emails_recipients` (
`email_recip_id` int(10) NOT NULL AUTO_INCREMENT,
`email_id` int(10) DEFAULT NULL COMMENT 'FK redcap_surveys_emails',
`participant_id` int(10) DEFAULT NULL COMMENT 'FK redcap_surveys_participants',
`static_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Static email address of recipient (used when participant has no email)',
`static_phone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Static phone number of recipient (used when participant has no phone number)',
`delivery_type` enum('EMAIL','VOICE_INITIATE','SMS_INITIATE','SMS_INVITE_MAKE_CALL','SMS_INVITE_RECEIVE_CALL','SMS_INVITE_WEB') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'EMAIL',
PRIMARY KEY (`email_recip_id`),
KEY `emt_id` (`email_id`),
KEY `participant_id` (`participant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Track email recipients';

CREATE TABLE `redcap_surveys_emails_send_rate` (
`esr_id` int(10) NOT NULL AUTO_INCREMENT,
`sent_begin_time` datetime DEFAULT NULL COMMENT 'Time email batch was sent',
`emails_per_batch` int(10) DEFAULT NULL COMMENT 'Number of emails sent in this batch',
`emails_per_minute` int(6) DEFAULT NULL COMMENT 'Number of emails sent per minute for this batch',
PRIMARY KEY (`esr_id`),
KEY `sent_begin_time` (`sent_begin_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Capture the rate that emails are sent per minute by REDCap';

CREATE TABLE `redcap_surveys_erase_twilio_log` (
`tl_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`ts` datetime DEFAULT NULL,
`sid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`sid_hash` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`tl_id`),
UNIQUE KEY `sid` (`sid`),
UNIQUE KEY `sid_hash` (`sid_hash`),
KEY `project_id` (`project_id`),
KEY `ts` (`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Temporary storage of Twilio logs to be deleted';

CREATE TABLE `redcap_surveys_login` (
`ts` datetime DEFAULT NULL,
`response_id` int(10) DEFAULT NULL,
`login_success` tinyint(1) NOT NULL DEFAULT '1',
KEY `response_id` (`response_id`),
KEY `ts_response_id_success` (`ts`,`response_id`,`login_success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_participants` (
`participant_id` int(10) NOT NULL AUTO_INCREMENT,
`survey_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`hash` varchar(10) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
`legacy_hash` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Migrated from RS',
`access_code` varchar(9) COLLATE utf8_unicode_ci DEFAULT NULL,
`access_code_numeral` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
`participant_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'NULL if public survey',
`participant_identifier` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`participant_phone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`delivery_preference` enum('EMAIL','VOICE_INITIATE','SMS_INITIATE','SMS_INVITE_MAKE_CALL','SMS_INVITE_RECEIVE_CALL','SMS_INVITE_WEB') COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`participant_id`),
UNIQUE KEY `access_code` (`access_code`),
UNIQUE KEY `access_code_numeral` (`access_code_numeral`),
UNIQUE KEY `hash` (`hash`),
UNIQUE KEY `legacy_hash` (`legacy_hash`),
KEY `event_id` (`event_id`),
KEY `participant_email_phone` (`participant_email`,`participant_phone`),
KEY `survey_event_email` (`survey_id`,`event_id`,`participant_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Table for survey data';

CREATE TABLE `redcap_surveys_phone_codes` (
`pc_id` int(10) NOT NULL AUTO_INCREMENT,
`phone_number` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`twilio_number` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`access_code` varchar(12) COLLATE utf8_unicode_ci DEFAULT NULL,
`project_id` int(10) DEFAULT NULL,
PRIMARY KEY (`pc_id`),
KEY `participant_twilio_phone` (`phone_number`,`twilio_number`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_queue` (
`sq_id` int(10) NOT NULL AUTO_INCREMENT,
`survey_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`active` int(1) NOT NULL DEFAULT '1' COMMENT 'Is it currently active?',
`auto_start` int(1) NOT NULL DEFAULT '0' COMMENT 'Automatically start if next after survey completion',
`condition_surveycomplete_survey_id` int(10) DEFAULT NULL COMMENT 'survey_id of trigger',
`condition_surveycomplete_event_id` int(10) DEFAULT NULL COMMENT 'event_id of trigger',
`condition_andor` enum('AND','OR') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Include survey complete AND/OR logic',
`condition_logic` text COLLATE utf8_unicode_ci COMMENT 'Logic using field values',
PRIMARY KEY (`sq_id`),
UNIQUE KEY `survey_event` (`survey_id`,`event_id`),
KEY `condition_surveycomplete_event_id` (`condition_surveycomplete_event_id`),
KEY `condition_surveycomplete_survey_event` (`condition_surveycomplete_survey_id`,`condition_surveycomplete_event_id`),
KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_queue_hashes` (
`project_id` int(10) NOT NULL DEFAULT '0',
`record` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
`hash` varchar(10) CHARACTER SET latin1 COLLATE latin1_general_cs DEFAULT NULL,
PRIMARY KEY (`project_id`,`record`),
UNIQUE KEY `hash` (`hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_response` (
`response_id` int(11) NOT NULL AUTO_INCREMENT,
`participant_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`instance` smallint(4) NOT NULL DEFAULT '1',
`start_time` datetime DEFAULT NULL,
`first_submit_time` datetime DEFAULT NULL,
`completion_time` datetime DEFAULT NULL,
`return_code` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
`results_code` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`response_id`),
UNIQUE KEY `participant_record` (`participant_id`,`record`,`instance`),
KEY `completion_time` (`completion_time`),
KEY `first_submit_time` (`first_submit_time`),
KEY `record_participant` (`record`,`participant_id`,`instance`),
KEY `results_code` (`results_code`),
KEY `return_code` (`return_code`),
KEY `start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_response_users` (
`response_id` int(10) DEFAULT NULL,
`username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
UNIQUE KEY `response_user` (`response_id`,`username`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_response_values` (
`response_id` int(10) DEFAULT NULL,
`project_id` int(10) NOT NULL DEFAULT '0',
`event_id` int(10) DEFAULT NULL,
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`field_name` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`value` text COLLATE utf8_unicode_ci,
`instance` smallint(4) DEFAULT NULL,
KEY `event_id_instance` (`event_id`,`instance`),
KEY `proj_record_field` (`project_id`,`record`,`field_name`),
KEY `project_field` (`project_id`,`field_name`),
KEY `response_id` (`response_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Storage for completed survey responses (archival purposes)';

CREATE TABLE `redcap_surveys_scheduler` (
`ss_id` int(10) NOT NULL AUTO_INCREMENT,
`survey_id` int(10) DEFAULT NULL,
`event_id` int(10) DEFAULT NULL,
`active` int(1) NOT NULL DEFAULT '1' COMMENT 'Is it currently active?',
`email_subject` text COLLATE utf8_unicode_ci COMMENT 'Survey invitation subject',
`email_content` text COLLATE utf8_unicode_ci COMMENT 'Survey invitation text',
`email_sender` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Static email address of sender',
`condition_surveycomplete_survey_id` int(10) DEFAULT NULL COMMENT 'survey_id of trigger',
`condition_surveycomplete_event_id` int(10) DEFAULT NULL COMMENT 'event_id of trigger',
`condition_andor` enum('AND','OR') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Include survey complete AND/OR logic',
`condition_logic` text COLLATE utf8_unicode_ci COMMENT 'Logic using field values',
`condition_send_time_option` enum('IMMEDIATELY','TIME_LAG','NEXT_OCCURRENCE','EXACT_TIME') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'When to send invites after condition is met',
`condition_send_time_lag_days` int(3) DEFAULT NULL COMMENT 'Wait X days to send invites after condition is met',
`condition_send_time_lag_hours` int(2) DEFAULT NULL COMMENT 'Wait X hours to send invites after condition is met',
`condition_send_time_lag_minutes` int(2) DEFAULT NULL COMMENT 'Wait X seconds to send invites after condition is met',
`condition_send_next_day_type` enum('DAY','WEEKDAY','WEEKENDDAY','SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Wait till specific day/time to send invites after condition is met',
`condition_send_next_time` time DEFAULT NULL COMMENT 'Wait till specific day/time to send invites after condition is met',
`condition_send_time_exact` datetime DEFAULT NULL COMMENT 'Wait till exact date/time to send invites after condition is met',
`delivery_type` enum('EMAIL','VOICE_INITIATE','SMS_INITIATE','SMS_INVITE_MAKE_CALL','SMS_INVITE_RECEIVE_CALL','PARTICIPANT_PREF','SMS_INVITE_WEB') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'EMAIL',
`reminder_type` enum('TIME_LAG','NEXT_OCCURRENCE','EXACT_TIME') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'When to send reminders after original invite is sent',
`reminder_timelag_days` int(3) DEFAULT NULL COMMENT 'Wait X days to send reminders',
`reminder_timelag_hours` int(2) DEFAULT NULL COMMENT 'Wait X hours to send reminders',
`reminder_timelag_minutes` int(2) DEFAULT NULL COMMENT 'Wait X seconds to send reminders',
`reminder_nextday_type` enum('DAY','WEEKDAY','WEEKENDDAY','SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Wait till specific day/time to send reminders',
`reminder_nexttime` time DEFAULT NULL COMMENT 'Wait till specific day/time to send reminders',
`reminder_exact_time` datetime DEFAULT NULL COMMENT 'Wait till exact date/time to send reminders',
`reminder_num` int(3) NOT NULL DEFAULT '0' COMMENT 'Reminder recurrence',
`reeval_before_send` int(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`ss_id`),
UNIQUE KEY `survey_event` (`survey_id`,`event_id`),
KEY `condition_surveycomplete_event_id` (`condition_surveycomplete_event_id`),
KEY `condition_surveycomplete_survey_event` (`condition_surveycomplete_survey_id`,`condition_surveycomplete_event_id`),
KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_scheduler_queue` (
`ssq_id` int(10) NOT NULL AUTO_INCREMENT,
`ss_id` int(10) DEFAULT NULL COMMENT 'FK for surveys_scheduler table',
`email_recip_id` int(10) DEFAULT NULL COMMENT 'FK for redcap_surveys_emails_recipients table',
`reminder_num` int(3) NOT NULL DEFAULT '0' COMMENT 'Email reminder instance (0 = original invitation)',
`record` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'NULL if record not created yet',
`instance` smallint(4) NOT NULL DEFAULT '1',
`scheduled_time_to_send` datetime DEFAULT NULL COMMENT 'Time invitation will be sent',
`status` enum('QUEUED','SENDING','SENT','DID NOT SEND','DELETED') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'QUEUED' COMMENT 'Survey invitation status (default=QUEUED)',
`time_sent` datetime DEFAULT NULL COMMENT 'Actual time invitation was sent',
`reason_not_sent` enum('EMAIL ADDRESS NOT FOUND','PHONE NUMBER NOT FOUND','EMAIL ATTEMPT FAILED','UNKNOWN','SURVEY ALREADY COMPLETED','VOICE/SMS SETTING DISABLED','ERROR SENDING SMS','ERROR MAKING VOICE CALL') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Explanation of why invitation did not send, if applicable',
PRIMARY KEY (`ssq_id`),
UNIQUE KEY `email_recip_id_record` (`email_recip_id`,`record`,`reminder_num`,`instance`),
UNIQUE KEY `ss_id_record` (`ss_id`,`record`,`reminder_num`,`instance`),
KEY `send_sent_status` (`scheduled_time_to_send`,`time_sent`,`status`),
KEY `status` (`status`),
KEY `time_sent` (`time_sent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_short_codes` (
`ts` datetime DEFAULT NULL,
`participant_id` int(10) DEFAULT NULL,
`code` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
UNIQUE KEY `code` (`code`),
KEY `participant_id_ts` (`participant_id`,`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_surveys_themes` (
`theme_id` int(10) NOT NULL AUTO_INCREMENT,
`theme_name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`ui_id` int(10) DEFAULT NULL COMMENT 'NULL = Theme is available to all users',
`theme_text_buttons` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_page` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_title` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_title` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_sectionheader` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_sectionheader` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_text_question` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
`theme_bg_question` varchar(6) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`theme_id`),
KEY `theme_name` (`theme_name`),
KEY `ui_id` (`ui_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_todo_list` (
`request_id` int(11) NOT NULL AUTO_INCREMENT,
`request_from` int(11) DEFAULT NULL,
`request_to` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`todo_type` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`action_url` text COLLATE utf8_unicode_ci,
`status` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`request_time` datetime DEFAULT NULL,
`project_id` int(10) DEFAULT NULL,
`request_completion_time` datetime DEFAULT NULL,
`request_completion_userid` int(11) DEFAULT NULL,
`comment` text COLLATE utf8_unicode_ci,
PRIMARY KEY (`request_id`),
KEY `project_id` (`project_id`),
KEY `request_completion_userid` (`request_completion_userid`),
KEY `request_from` (`request_from`),
KEY `request_time` (`request_time`),
KEY `status` (`status`),
KEY `todo_type` (`todo_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_two_factor_response` (
`tf_id` int(10) NOT NULL AUTO_INCREMENT,
`user_id` int(10) DEFAULT NULL,
`time_sent` datetime DEFAULT NULL,
`phone_number` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`verified` tinyint(1) NOT NULL DEFAULT '0',
PRIMARY KEY (`tf_id`),
KEY `phone_number` (`phone_number`),
KEY `time_sent` (`time_sent`),
KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_user_information` (
`ui_id` int(10) NOT NULL AUTO_INCREMENT,
`username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`user_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Primary email',
`user_email2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Secondary email',
`user_email3` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Tertiary email',
`user_phone` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`user_phone_sms` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`user_firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`user_lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`user_inst_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`super_user` int(1) NOT NULL DEFAULT '0',
`user_creation` datetime DEFAULT NULL COMMENT 'Time user account was created',
`user_firstvisit` datetime DEFAULT NULL,
`user_firstactivity` datetime DEFAULT NULL,
`user_lastactivity` datetime DEFAULT NULL,
`user_lastlogin` datetime DEFAULT NULL,
`user_suspended_time` datetime DEFAULT NULL,
`user_expiration` datetime DEFAULT NULL COMMENT 'Time at which the user will be automatically suspended from REDCap',
`user_access_dashboard_view` datetime DEFAULT NULL,
`user_access_dashboard_email_queued` enum('QUEUED','SENDING') COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Tracks status of email reminder for User Access Dashboard',
`user_sponsor` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Username of user''s sponsor or contact person',
`user_comments` text COLLATE utf8_unicode_ci COMMENT 'Miscellaneous comments about user',
`allow_create_db` int(1) NOT NULL DEFAULT '1',
`email_verify_code` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Primary email verification code',
`email2_verify_code` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Secondary email verification code',
`email3_verify_code` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Tertiary email verification code',
`datetime_format` enum('M-D-Y_24','M-D-Y_12','M/D/Y_24','M/D/Y_12','M.D.Y_24','M.D.Y_12','D-M-Y_24','D-M-Y_12','D/M/Y_24','D/M/Y_12','D.M.Y_24','D.M.Y_12','Y-M-D_24','Y-M-D_12','Y/M/D_24','Y/M/D_12','Y.M.D_24','Y.M.D_12') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'M/D/Y_12' COMMENT 'User''s preferred datetime viewing format',
`number_format_decimal` enum('.',',') COLLATE utf8_unicode_ci NOT NULL DEFAULT '.' COMMENT 'User''s preferred decimal format',
`number_format_thousands_sep` enum(',','.','','SPACE','''') COLLATE utf8_unicode_ci NOT NULL DEFAULT ',' COMMENT 'User''s preferred thousands separator',
`two_factor_auth_secret` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
`display_on_email_users` int(1) NOT NULL DEFAULT '1',
`two_factor_auth_twilio_prompt_phone` tinyint(1) NOT NULL DEFAULT '1',
`two_factor_auth_code_expiration` int(3) NOT NULL DEFAULT '2',
`api_token` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`ui_id`),
UNIQUE KEY `api_token` (`api_token`),
UNIQUE KEY `email2_verify_code` (`email2_verify_code`),
UNIQUE KEY `email3_verify_code` (`email3_verify_code`),
UNIQUE KEY `email_verify_code` (`email_verify_code`),
UNIQUE KEY `username` (`username`),
KEY `two_factor_auth_secret` (`two_factor_auth_secret`),
KEY `user_access_dashboard_email_queued` (`user_access_dashboard_email_queued`),
KEY `user_access_dashboard_view` (`user_access_dashboard_view`),
KEY `user_comments` (`user_comments`(255)),
KEY `user_creation` (`user_creation`),
KEY `user_email` (`user_email`),
KEY `user_expiration` (`user_expiration`),
KEY `user_firstactivity` (`user_firstactivity`),
KEY `user_firstname` (`user_firstname`),
KEY `user_firstvisit` (`user_firstvisit`),
KEY `user_inst_id` (`user_inst_id`),
KEY `user_lastactivity` (`user_lastactivity`),
KEY `user_lastlogin` (`user_lastlogin`),
KEY `user_lastname` (`user_lastname`),
KEY `user_sponsor` (`user_sponsor`),
KEY `user_suspended_time` (`user_suspended_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_user_rights` (
`project_id` int(10) NOT NULL DEFAULT '0',
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
`expiration` date DEFAULT NULL,
`role_id` int(10) DEFAULT NULL,
`group_id` int(10) DEFAULT NULL,
`lock_record` int(1) NOT NULL DEFAULT '0',
`lock_record_multiform` int(1) NOT NULL DEFAULT '0',
`lock_record_customize` int(1) NOT NULL DEFAULT '0',
`data_export_tool` int(1) NOT NULL DEFAULT '1',
`data_import_tool` int(1) NOT NULL DEFAULT '1',
`data_comparison_tool` int(1) NOT NULL DEFAULT '1',
`data_logging` int(1) NOT NULL DEFAULT '1',
`file_repository` int(1) NOT NULL DEFAULT '1',
`double_data` int(1) NOT NULL DEFAULT '0',
`user_rights` int(1) NOT NULL DEFAULT '1',
`data_access_groups` int(1) NOT NULL DEFAULT '1',
`graphical` int(1) NOT NULL DEFAULT '1',
`reports` int(1) NOT NULL DEFAULT '1',
`design` int(1) NOT NULL DEFAULT '0',
`calendar` int(1) NOT NULL DEFAULT '1',
`data_entry` text COLLATE utf8_unicode_ci,
`api_token` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
`api_export` int(1) NOT NULL DEFAULT '0',
`api_import` int(1) NOT NULL DEFAULT '0',
`mobile_app` int(1) NOT NULL DEFAULT '0',
`mobile_app_download_data` int(1) NOT NULL DEFAULT '0',
`record_create` int(1) NOT NULL DEFAULT '1',
`record_rename` int(1) NOT NULL DEFAULT '0',
`record_delete` int(1) NOT NULL DEFAULT '0',
`dts` int(1) NOT NULL DEFAULT '0' COMMENT 'DTS adjudication page',
`participants` int(1) NOT NULL DEFAULT '1',
`data_quality_design` int(1) NOT NULL DEFAULT '0',
`data_quality_execute` int(1) NOT NULL DEFAULT '0',
`data_quality_resolution` int(1) NOT NULL DEFAULT '0' COMMENT '0=No access, 1=View only, 2=Respond, 3=Open, close, respond, 4=Open only, 5=Open and respond',
`random_setup` int(1) NOT NULL DEFAULT '0',
`random_dashboard` int(1) NOT NULL DEFAULT '0',
`random_perform` int(1) NOT NULL DEFAULT '0',
`realtime_webservice_mapping` int(1) NOT NULL DEFAULT '0' COMMENT 'User can map fields for RTWS',
`realtime_webservice_adjudicate` int(1) NOT NULL DEFAULT '0' COMMENT 'User can adjudicate data for RTWS',
PRIMARY KEY (`project_id`,`username`),
UNIQUE KEY `api_token` (`api_token`),
KEY `group_id` (`group_id`),
KEY `project_id` (`project_id`),
KEY `role_id` (`role_id`),
KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_user_roles` (
`role_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`role_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Name of user role',
`lock_record` int(1) NOT NULL DEFAULT '0',
`lock_record_multiform` int(1) NOT NULL DEFAULT '0',
`lock_record_customize` int(1) NOT NULL DEFAULT '0',
`data_export_tool` int(1) NOT NULL DEFAULT '1',
`data_import_tool` int(1) NOT NULL DEFAULT '1',
`data_comparison_tool` int(1) NOT NULL DEFAULT '1',
`data_logging` int(1) NOT NULL DEFAULT '1',
`file_repository` int(1) NOT NULL DEFAULT '1',
`double_data` int(1) NOT NULL DEFAULT '0',
`user_rights` int(1) NOT NULL DEFAULT '1',
`data_access_groups` int(1) NOT NULL DEFAULT '1',
`graphical` int(1) NOT NULL DEFAULT '1',
`reports` int(1) NOT NULL DEFAULT '1',
`design` int(1) NOT NULL DEFAULT '0',
`calendar` int(1) NOT NULL DEFAULT '1',
`data_entry` text COLLATE utf8_unicode_ci,
`api_export` int(1) NOT NULL DEFAULT '0',
`api_import` int(1) NOT NULL DEFAULT '0',
`mobile_app` int(1) NOT NULL DEFAULT '0',
`mobile_app_download_data` int(1) NOT NULL DEFAULT '0',
`record_create` int(1) NOT NULL DEFAULT '1',
`record_rename` int(1) NOT NULL DEFAULT '0',
`record_delete` int(1) NOT NULL DEFAULT '0',
`dts` int(1) NOT NULL DEFAULT '0' COMMENT 'DTS adjudication page',
`participants` int(1) NOT NULL DEFAULT '1',
`data_quality_design` int(1) NOT NULL DEFAULT '0',
`data_quality_execute` int(1) NOT NULL DEFAULT '0',
`data_quality_resolution` int(1) NOT NULL DEFAULT '0' COMMENT '0=No access, 1=View only, 2=Respond, 3=Open, close, respond',
`random_setup` int(1) NOT NULL DEFAULT '0',
`random_dashboard` int(1) NOT NULL DEFAULT '0',
`random_perform` int(1) NOT NULL DEFAULT '0',
`realtime_webservice_mapping` int(1) NOT NULL DEFAULT '0' COMMENT 'User can map fields for RTWS',
`realtime_webservice_adjudicate` int(1) NOT NULL DEFAULT '0' COMMENT 'User can adjudicate data for RTWS',
PRIMARY KEY (`role_id`),
KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_user_whitelist` (
`username` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_validation_types` (
`validation_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Unique name for Data Dictionary',
`validation_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Label in Online Designer',
`regex_js` text COLLATE utf8_unicode_ci,
`regex_php` text COLLATE utf8_unicode_ci,
`data_type` enum('date','datetime','datetime_seconds','email','integer','mrn','number','number_comma_decimal','phone','postal_code','ssn','text','time','char') COLLATE utf8_unicode_ci DEFAULT NULL,
`legacy_value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
`visible` int(1) NOT NULL DEFAULT '1' COMMENT 'Show in Online Designer?',
UNIQUE KEY `validation_name` (`validation_name`),
KEY `data_type` (`data_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `redcap_web_service_cache` (
`cache_id` int(10) NOT NULL AUTO_INCREMENT,
`project_id` int(10) DEFAULT NULL,
`service` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`category` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
`value` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
`label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
PRIMARY KEY (`cache_id`),
UNIQUE KEY `project_service_cat_value` (`project_id`,`service`,`category`,`value`),
KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE `redcap_actions`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`recipient_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_auth`
ADD FOREIGN KEY (`password_question`) REFERENCES `redcap_auth_questions` (`qid`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_crons_history`
ADD FOREIGN KEY (`cron_id`) REFERENCES `redcap_crons` (`cron_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_data_access_groups`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_data_quality_resolutions`
ADD FOREIGN KEY (`status_id`) REFERENCES `redcap_data_quality_status` (`status_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`upload_doc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`user_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_data_quality_rules`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_data_quality_status`
ADD FOREIGN KEY (`assigned_user_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`rule_id`) REFERENCES `redcap_data_quality_rules` (`rule_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_log_view`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`user_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_log_view_data`
ADD FOREIGN KEY (`md_id`) REFERENCES `redcap_ddp_records_data` (`md_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`ml_id`) REFERENCES `redcap_ddp_log_view` (`ml_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_mapping`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_preview_fields`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_records`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_ddp_records_data`
ADD FOREIGN KEY (`map_id`) REFERENCES `redcap_ddp_mapping` (`map_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`mr_id`) REFERENCES `redcap_ddp_records` (`mr_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_docs`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_docs_to_edocs`
ADD FOREIGN KEY (`doc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`docs_id`) REFERENCES `redcap_docs` (`docs_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_edocs_metadata`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_esignatures`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_events_arms`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_events_calendar`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_events_forms`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_events_metadata`
ADD FOREIGN KEY (`arm_id`) REFERENCES `redcap_events_arms` (`arm_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_events_repeat`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_external_links`
ADD FOREIGN KEY (`link_to_project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_external_links_dags`
ADD FOREIGN KEY (`ext_id`) REFERENCES `redcap_external_links` (`ext_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_external_links_exclude_projects`
ADD FOREIGN KEY (`ext_id`) REFERENCES `redcap_external_links` (`ext_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_external_links_users`
ADD FOREIGN KEY (`ext_id`) REFERENCES `redcap_external_links` (`ext_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_folders`
ADD FOREIGN KEY (`ui_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_folders_projects`
ADD FOREIGN KEY (`folder_id`) REFERENCES `redcap_folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`ui_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_instrument_zip`
ADD FOREIGN KEY (`iza_id`) REFERENCES `redcap_instrument_zip_authors` (`iza_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_library_map`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_locking_data`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_locking_labels`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_log_view_requests`
ADD FOREIGN KEY (`log_view_id`) REFERENCES `redcap_log_view` (`log_view_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_metadata`
ADD FOREIGN KEY (`edoc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_metadata_archive`
ADD FOREIGN KEY (`edoc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`pr_id`) REFERENCES `redcap_metadata_prod_revisions` (`pr_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_metadata_prod_revisions`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`ui_id_approver`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`ui_id_requester`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_metadata_temp`
ADD FOREIGN KEY (`edoc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_mobile_app_files`
ADD FOREIGN KEY (`doc_id`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`user_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_mobile_app_log`
ADD FOREIGN KEY (`log_event_id`) REFERENCES `redcap_log_event` (`log_event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_new_record_cache`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_project_checklist`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_projects`
ADD FOREIGN KEY (`created_by`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_auth_event_id1`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_auth_event_id2`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_auth_event_id3`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`template_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_projects_templates`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_pub_articles`
ADD FOREIGN KEY (`pubsrc_id`) REFERENCES `redcap_pub_sources` (`pubsrc_id`);

ALTER TABLE `redcap_pub_authors`
ADD FOREIGN KEY (`article_id`) REFERENCES `redcap_pub_articles` (`article_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_pub_matches`
ADD FOREIGN KEY (`article_id`) REFERENCES `redcap_pub_articles` (`article_id`) ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON UPDATE CASCADE;

ALTER TABLE `redcap_pub_mesh_terms`
ADD FOREIGN KEY (`article_id`) REFERENCES `redcap_pub_articles` (`article_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_randomization`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event1`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event10`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event11`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event12`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event13`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event14`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event15`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event2`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event3`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event4`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event5`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event6`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event7`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event8`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`source_event9`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`target_event`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_randomization_allocation`
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`rid`) REFERENCES `redcap_randomization` (`rid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_access_dags`
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_access_roles`
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`role_id`) REFERENCES `redcap_user_roles` (`role_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_access_users`
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_fields`
ADD FOREIGN KEY (`limiter_event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_filter_dags`
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_reports_filter_events`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`report_id`) REFERENCES `redcap_reports` (`report_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_sendit_recipients`
ADD FOREIGN KEY (`document_id`) REFERENCES `redcap_sendit_docs` (`document_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys`
ADD FOREIGN KEY (`confirmation_email_attachment`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`logo`) REFERENCES `redcap_edocs_metadata` (`doc_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`theme`) REFERENCES `redcap_surveys_themes` (`theme_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_emails`
ADD FOREIGN KEY (`email_sender`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE SET NULL,
ADD FOREIGN KEY (`survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_emails_recipients`
ADD FOREIGN KEY (`email_id`) REFERENCES `redcap_surveys_emails` (`email_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`participant_id`) REFERENCES `redcap_surveys_participants` (`participant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_erase_twilio_log`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_login`
ADD FOREIGN KEY (`response_id`) REFERENCES `redcap_surveys_response` (`response_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_participants`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_phone_codes`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_queue`
ADD FOREIGN KEY (`condition_surveycomplete_event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`condition_surveycomplete_survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_queue_hashes`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_response`
ADD FOREIGN KEY (`participant_id`) REFERENCES `redcap_surveys_participants` (`participant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_response_users`
ADD FOREIGN KEY (`response_id`) REFERENCES `redcap_surveys_response` (`response_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_response_values`
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`response_id`) REFERENCES `redcap_surveys_response` (`response_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_scheduler`
ADD FOREIGN KEY (`condition_surveycomplete_event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`condition_surveycomplete_survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`event_id`) REFERENCES `redcap_events_metadata` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`survey_id`) REFERENCES `redcap_surveys` (`survey_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_scheduler_queue`
ADD FOREIGN KEY (`email_recip_id`) REFERENCES `redcap_surveys_emails_recipients` (`email_recip_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`ss_id`) REFERENCES `redcap_surveys_scheduler` (`ss_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_short_codes`
ADD FOREIGN KEY (`participant_id`) REFERENCES `redcap_surveys_participants` (`participant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_surveys_themes`
ADD FOREIGN KEY (`ui_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_todo_list`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`request_completion_userid`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL,
ADD FOREIGN KEY (`request_from`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_two_factor_response`
ADD FOREIGN KEY (`user_id`) REFERENCES `redcap_user_information` (`ui_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_user_rights`
ADD FOREIGN KEY (`group_id`) REFERENCES `redcap_data_access_groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`role_id`) REFERENCES `redcap_user_roles` (`role_id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `redcap_user_roles`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `redcap_web_service_cache`
ADD FOREIGN KEY (`project_id`) REFERENCES `redcap_projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE;
-- REDCAP INSTALLATION INITIAL DATA --

INSERT INTO redcap_user_information (username, user_email, user_firstname, user_lastname, super_user, user_firstvisit) VALUES
('site_admin', 'joe.user@projectredcap.org', 'Joe', 'User', 1, now());

INSERT INTO redcap_crons (cron_name, cron_description, cron_enabled, cron_frequency, cron_max_run_time, cron_instances_max, cron_instances_current, cron_last_run_end, cron_times_failed, cron_external_url) VALUES
('PubMed', 'Query the PubMed API to find publications associated with PIs in REDCap, and store publication attributes and PI/project info. Emails will then be sent to any PIs that have been found to have publications in PubMed, and (if applicable) will be asked to associate their publication to a REDCap project.', 'DISABLED', 86400, 7200, 1, 0, NULL, 0, NULL),
('RemoveTempAndDeletedFiles', 'Delete all files from the REDCap temp directory, and delete all edoc and Send-It files marked for deletion.', 'ENABLED', 120, 600, 1, 0, NULL, 0, NULL),
('ExpireSurveys', 'For any surveys where an expiration timestamp is set, if the timestamp <= NOW, then make the survey inactive.', 'ENABLED', 120, 600, 1, 0, NULL, 0, NULL),
('SurveyInvitationEmailer', 'Mailer that sends any survey invitations that have been scheduled.', 'ENABLED', 60, 1800, 5, 0, NULL, 0, NULL),
('DeleteProjects', 'Delete all projects that are scheduled for permanent deletion', 'ENABLED', 300, 1200, 1, 0, NULL, 0, NULL),
('ClearIPCache',  'Clear all IP addresses older than X minutes from the redcap_ip_cache table.',  'ENABLED',  180,  60,  1,  0, NULL , 0, NULL),
('ExpireUsers', 'For any users whose expiration timestamp is set, if the timestamp <= NOW, then suspend the user''s account and set expiration time back to NULL.', 'ENABLED', 120, 600, 1, 0, NULL, 0, NULL),
('WarnUsersAccountExpiration', 'For any users whose expiration timestamp is set, if the expiration time is less than X days from now, then email the user to warn them of their impending account expiration.', 'ENABLED', 86400, 600, 1, 0, NULL, 0, NULL),
('SuspendInactiveUsers', 'For any users whose last login time exceeds the defined max days of inactivity, auto-suspend their account (if setting enabled).', 'ENABLED', 86400, 600, 1, 0, NULL, 0, NULL),
('ReminderUserAccessDashboard', 'At a regular interval, email all users to remind them to visit the User Access Dashboard page. Enables the ReminderUserAccessDashboardEmail cron job.', 'ENABLED', 86400, 600, 1, 0, NULL, 0, NULL),
('ReminderUserAccessDashboardEmail', 'Email all users in batches to remind them to visit the User Access Dashboard page. Will disable itself when done.', 'DISABLED', 60, 1800, 5, 0, NULL, 0, NULL),
('DDPQueueRecordsAllProjects', 'Queue records that are ready to be fetched from the external source system via the DDP service.', 'ENABLED', 300, 600, 1, 0, NULL, 0, NULL),
('DDPFetchRecordsAllProjects', 'Fetch data from the external source system for records already queued by the DDP service.', 'ENABLED', 60, 1800, 10, 0, NULL, 0, NULL),
('PurgeCronHistory', 'Purges all rows from the crons history table that are older than one week.', 'ENABLED', 86400, 600, 1, 0, NULL, 0, NULL),
('UpdateUserPasswordAlgo', 'Send email to all Table-based users telling them to log in for the purpose of upgrading their password security (one time only)', 'DISABLED', 86400, 7200, 1, 0, NULL, 0, NULL),
('AutomatedSurveyInvitationsDatediffChecker', 'Check all conditional logic in Automated Surveys Invitations that uses "today" inside datediff() function', 'ENABLED', 43200, 7200, 1, 0, NULL, 0, NULL),
('ClearSurveyShortCodes', 'Clear all survey short codes older than X minutes.',  'ENABLED',  300,  60,  1,  0, NULL , 0, NULL),
('ClearLogViewRequests', 'Clear all items from redcap_log_view_requests table older than X hours.',  'ENABLED',  1800,  300,  1,  0, NULL , 0, NULL),
('EraseTwilioLog', 'Clear all items from redcap_surveys_erase_twilio_log table.',  'ENABLED',  120,  300,  1,  0, NULL , 0, NULL),
('ClearNewRecordCache', 'Clear all items from redcap_new_record_cache table older than X hours.',  'ENABLED',  10800,  300,  1,  0, NULL , 0, NULL),
('FixStuckSurveyInvitations', 'Reset any survey invitations stuck in SENDING status for than X hours back to QUEUED status.',  'ENABLED',  3600,  300,  1,  0, NULL , 0, NULL),
('DbUsage', 'Record the daily space usage of the database tables and the uploaded files stored on the server.', 'ENABLED', 86400, 600, 1, 0, NULL, 0, NULL);

INSERT INTO redcap_auth_questions (qid, question) VALUES
(1, 'What was your childhood nickname?'),
(2, 'In what city did you meet your spouse/significant other?'),
(3, 'What is the name of your favorite childhood friend?'),
(4, 'What street did you live on in third grade?'),
(5, 'What is your oldest sibling''s birthday month and year? (e.g., January 1900)'),
(6, 'What is the middle name of your oldest child?'),
(7, 'What is your oldest sibling''s middle name?'),
(8, 'What school did you attend for sixth grade?'),
(9, 'What was your childhood phone number including area code? (e.g., 000-000-0000)'),
(10, 'What is your oldest cousin''s first and last name?'),
(11, 'What was the name of your first stuffed animal?'),
(12, 'In what city or town did your mother and father meet?'),
(13, 'Where were you when you had your first kiss?'),
(14, 'What is the first name of the boy or girl that you first kissed?'),
(15, 'What was the last name of your third grade teacher?'),
(16, 'In what city does your nearest sibling live?'),
(17, 'What is your oldest brother''s birthday month and year? (e.g., January 1900)'),
(18, 'What is your maternal grandmother''s maiden name?'),
(19, 'In what city or town was your first job?'),
(20, 'What is the name of the place your wedding reception was held?'),
(21, 'What is the name of a college you applied to but didn''t attend?');

INSERT INTO redcap_config (field_name, value) VALUES
('send_emails_admin_tasks', '1'),
('display_project_xml_backup_option', '1'),
('cross_domain_access_control', ''),
('google_cloud_storage_edocs_bucket', ''),
('google_cloud_storage_temp_bucket', ''),
('amazon_s3_endpoint', ''),
('proxy_username_password', ''),
('homepage_contact_url', ''),
('bioportal_api_token', ''),
('two_factor_auth_ip_range_alt', ''),
('two_factor_auth_trust_period_days_alt', '0'),
('two_factor_auth_trust_period_days', '0'),
('two_factor_auth_email_enabled', '1'),
('two_factor_auth_authenticator_enabled', '1'),
('two_factor_auth_ip_check_enabled', '0'),
('two_factor_auth_ip_range', ''),
('two_factor_auth_ip_range_include_private', '0'),
('two_factor_auth_duo_enabled', '0'),
('two_factor_auth_duo_ikey', ''),
('two_factor_auth_duo_skey', ''),
('two_factor_auth_duo_hostname', ''),
('bioportal_ontology_list_cache_time', ''),
('bioportal_ontology_list', ''),
('redcap_survey_base_url', ''),
('enable_ontology_auto_suggest', '1'),
('enable_survey_text_to_speech', '1'),
('enable_field_attachment_video_url', '1'),
('google_oauth2_client_id', ''),
('google_oauth2_client_secret', ''),
('two_factor_auth_twilio_enabled', '0'),
('two_factor_auth_twilio_account_sid', ''),
('two_factor_auth_twilio_auth_token', ''),
('two_factor_auth_twilio_from_number', ''),
('two_factor_auth_enabled', '0'),
('allow_kill_mysql_process', '0'),
('mobile_app_enabled', '1'),
('twilio_display_info_project_setup', '0'),
('twilio_enabled_global', '1'),
('twilio_enabled_by_super_users_only', '1'),
('field_comment_log_enabled_default', '1'),
('from_email', ''),
('promis_enabled', '1'),
('promis_api_base_url', 'https://www.redcap-cats.org/promis_api/'),
('sams_logout', ''),
('promis_registration_id', ''),
('promis_token', ''),
('hook_functions_file', ''),
('project_encoding', ''),
('default_datetime_format', 'M/D/Y_12'),
('default_number_format_decimal', '.'),
('default_number_format_thousands_sep', ','),
('homepage_announcement', ''),
('password_algo', 'md5'),
('password_recovery_custom_text', ''),
('user_access_dashboard_enable', '1'),
('user_access_dashboard_custom_notification', ''),
('suspend_users_inactive_send_email', 1),
('suspend_users_inactive_days', 180),
('suspend_users_inactive_type', ''),
('page_hit_threshold_per_minute', '600'),
('enable_http_compression', '1'),
('realtime_webservice_data_fetch_interval', '24'),
('realtime_webservice_url_metadata', ''),
('realtime_webservice_url_data', ''),
('realtime_webservice_url_user_access', ''),
('realtime_webservice_global_enabled', '0'),
('realtime_webservice_custom_text', ''),
('realtime_webservice_display_info_project_setup', '1'),
('realtime_webservice_source_system_custom_name', ''),
('realtime_webservice_user_rights_super_users_only', '1'),
('realtime_webservice_stop_fetch_inactivity_days', '7'),
('amazon_s3_key', ''),
('amazon_s3_secret', ''),
('amazon_s3_bucket', ''),
('system_offline_message', ''),
('openid_provider_url', ''),
('openid_provider_name', ''),
('file_attachment_upload_max', ''),
('data_entry_trigger_enabled', '1'),
('redcap_base_url_display_error_on_mismatch', '1'),
('email_domain_whitelist', ''),
('helpfaq_custom_text', ''),
('randomization_global', '1'),
('login_custom_text', ''),
('auto_prod_changes', '2'),
('enable_edit_prod_events', '1'),
('allow_create_db_default', '1'),
('api_enabled', '1'),
('auth_meth_global', 'none'),
('auto_report_stats', '1'),
('auto_report_stats_last_sent', '2000-01-01'),
('autologout_timer', '30'),
('certify_text_create', ''),
('certify_text_prod', ''),
('homepage_custom_text', ''),
('dts_enabled_global', '0'),
('display_nonauth_projects', '1'),
('display_project_logo_institution', '0'),
('display_today_now_button', '1'),
('edoc_field_option_enabled', '1'),
('edoc_upload_max', ''),
('edoc_storage_option', '0'),
('file_repository_upload_max', ''),
('file_repository_enabled', '1'),
('temp_files_last_delete', now()),
('edoc_path', ''),
('enable_edit_survey_response', '1'),
('enable_plotting', '2'),
('enable_plotting_survey_results', '1'),
('enable_projecttype_singlesurvey', '1'),
('enable_projecttype_forms', '1'),
('enable_projecttype_singlesurveyforms', '1'),
('enable_url_shortener', '1'),
('enable_user_whitelist', '0'),
('logout_fail_limit', '5'),
('logout_fail_window', '15'),
('footer_links', ''),
('footer_text', ''),
('google_translate_enabled', '0'),
('googlemap_key',''),
('grant_cite', ''),
('headerlogo', ''),
('homepage_contact', ''),
('homepage_contact_email', ''),
('homepage_grant_cite', ''),
('identifier_keywords', 'name, street, address, city, county, precinct, zip, postal, date, phone, fax, mail, ssn, social security, mrn, dob, dod, medical, record, id, age'),
('institution', ''),
('language_global','English'),
('login_autocomplete_disable', '0'),
('login_logo', ''),
('my_profile_enable_edit','1'),
('password_history_limit','0'),
('password_reset_duration','0'),
('project_contact_email', ''),
('project_contact_name', ''),
('project_language', 'English'),
('proxy_hostname', ''),
('pub_matching_enabled', '0'),
('redcap_base_url', ''),
('pub_matching_emails', '0'),
('pub_matching_email_days', '7'),
('pub_matching_email_limit', '3'),
('pub_matching_email_text', ''),
('pub_matching_email_subject', ''),
('pub_matching_institution', 'Vanderbilt\nMeharry'),
('redcap_last_install_date', CURRENT_DATE),
('redcap_version', '4.0.0'),
('sendit_enabled', '1'),
('sendit_upload_max', ''),
('shared_library_enabled', '1'),
('shibboleth_logout', ''),
('shibboleth_username_field', 'none'),
('site_org_type', ''),
('superusers_only_create_project', '0'),
('superusers_only_move_to_prod', '1'),
('system_offline', '0');

INSERT INTO `redcap_pub_sources` (`pubsrc_id`, `pubsrc_name`, `pubsrc_last_crawl_time`) VALUES
(1, 'PubMed', NULL);

INSERT INTO `redcap_validation_types` (`validation_name`, `validation_label`, `regex_js`, `regex_php`, `data_type`, `legacy_value`, `visible`) VALUES
('alpha_only', 'Letters only', '/^[a-z]+$/i', '/^[a-z]+$/i', 'text', NULL, 0),
('date_dmy', 'Date (D-M-Y)', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4}))$/', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4}))$/', 'date', NULL, 1),
('date_mdy', 'Date (M-D-Y)', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4}))$/', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4}))$/', 'date', NULL, 1),
('date_ymd', 'Date (Y-M-D)', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31))))$/', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31))))$/', 'date', 'date', 1),
('datetime_dmy', 'Datetime (D-M-Y H:M)', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4})) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4})) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', 'datetime', NULL, 1),
('datetime_mdy', 'Datetime (M-D-Y H:M)', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4})) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4})) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', 'datetime', NULL, 1),
('datetime_seconds_dmy', 'Datetime w/ seconds (D-M-Y H:M:S)', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4})) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', '/^((29([-\\/])02\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1\\d|2[0-8])([-\\/])(0[1-9]|1[012]))|((29|30)([-\\/])(0[13-9]|1[012]))|(31([-\\/])(0[13578]|1[02])))(\\11|\\15|\\18)\\d{4})) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', 'datetime_seconds', NULL, 1),
('datetime_seconds_mdy', 'Datetime w/ seconds (M-D-Y H:M:S)', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4})) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', '/^((02([-\\/])29\\3(\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00)))|((((0[1-9]|1[012])([-\\/])(0[1-9]|1\\d|2[0-8]))|((0[13-9]|1[012])([-\\/])(29|30))|((0[13578]|1[02])([-\\/])31))(\\11|\\15|\\19)\\d{4})) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', 'datetime_seconds', NULL, 1),
('datetime_seconds_ymd', 'Datetime w/ seconds (Y-M-D H:M:S)', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31)))) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31)))) (\\d|[0-1]\\d|[2][0-3])(:[0-5]\\d){2}$/', 'datetime_seconds', 'datetime_seconds', 1),
('datetime_ymd', 'Datetime (Y-M-D H:M)', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31)))) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', '/^(((\\d{2}([13579][26]|[2468][048]|04|08)|(1600|2[048]00))([-\\/])02(\\6)29)|(\\d{4}([-\\/])((0[1-9]|1[012])(\\9)(0[1-9]|1\\d|2[0-8])|((0[13-9]|1[012])(\\9)(29|30))|((0[13578]|1[02])(\\9)31)))) (\\d|[0-1]\\d|[2][0-3]):[0-5]\\d$/', 'datetime', 'datetime', 1),
('email', 'Email', '/^([_a-z0-9-'']+)([.+][_a-z0-9-'']+)*@([a-z0-9-]+)(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$/i', '/^([_a-z0-9-'']+)([.+][_a-z0-9-'']+)*@([a-z0-9-]+)(\\.[a-z0-9-]+)*(\\.[a-z]{2,4})$/i', 'email', NULL, 1),
('integer', 'Integer', '/^[-+]?\\b\\d+\\b$/', '/^[-+]?\\b\\d+\\b$/', 'integer', 'int', 1),
('mrn_10d', 'MRN (10 digits)', '/^\\d{10}$/', '/^\\d{10}$/', 'text', NULL, 0),
('number', 'Number', '/^[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?$/', '/^[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?$/', 'number', 'float', 1),
('number_1dp', 'Number (1 decimal place)', '/^-?\\d+\\.\\d$/', '/^-?\\d+\\.\\d$/', 'number', NULL, 0),
('number_2dp', 'Number (2 decimal places)', '/^-?\\d+\\.\\d{2}$/', '/^-?\\d+\\.\\d{2}$/', 'number', NULL, 0),
('number_3dp', 'Number (3 decimal places)', '/^-?\\d+\\.\\d{3}$/', '/^-?\\d+\\.\\d{3}$/', 'number', NULL, 0),
('number_4dp', 'Number (4 decimal places)', '/^-?\\d+\\.\\d{4}$/', '/^-?\\d+\\.\\d{4}$/', 'number', NULL, 0),
('phone', 'Phone (North America)', '/^(?:\\(?([2-9]0[1-9]|[2-9]1[02-9]|[2-9][2-9][0-9])\\)?)\\s*(?:[.-]\\s*)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?$/', '/^(?:\\(?([2-9]0[1-9]|[2-9]1[02-9]|[2-9][2-9][0-9])\\)?)\\s*(?:[.-]\\s*)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?$/', 'phone', NULL, 1),
('phone_australia', 'Phone (Australia)', '/^(\\(0[2-8]\\)|0[2-8])\\s*\\d{4}\\s*\\d{4}$/', '/^(\\(0[2-8]\\)|0[2-8])\\s*\\d{4}\\s*\\d{4}$/', 'phone', NULL, 0),
('postalcode_australia', 'Postal Code (Australia)', '/^\\d{4}$/', '/^\\d{4}$/', 'postal_code', NULL, 0),
('postalcode_canada', 'Postal Code (Canada)', '/^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1}\\s*\\d{1}[A-Z]{1}\\d{1}$/i', '/^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1}\\s*\\d{1}[A-Z]{1}\\d{1}$/i', 'postal_code', NULL, 0),
('ssn', 'Social Security Number (U.S.)', '/^\\d{3}-\\d\\d-\\d{4}$/', '/^\\d{3}-\\d\\d-\\d{4}$/', 'ssn', NULL, 0),
('time', 'Time (HH:MM)', '/^([0-9]|[0-1][0-9]|[2][0-3]):([0-5][0-9])$/', '/^([0-9]|[0-1][0-9]|[2][0-3]):([0-5][0-9])$/', 'time', NULL, 1),
('time_mm_ss', 'Time (MM:SS)', '/^[0-5]\\d:[0-5]\\d$/', '/^[0-5]\\d:[0-5]\\d$/', 'time', NULL, 0),
('vmrn', 'Vanderbilt MRN', '/^[0-9]{4,9}$/', '/^[0-9]{4,9}$/', 'mrn', NULL, 0),
('zipcode', 'Zipcode (U.S.)', '/^\\d{5}(-\\d{4})?$/', '/^\\d{5}(-\\d{4})?$/', 'postal_code', NULL, 1),
('number_comma_decimal', 'Number (comma as decimal)', '/^[-+]?[0-9]*,?[0-9]+([eE][-+]?[0-9]+)?$/', '/^[-+]?[0-9]*,?[0-9]+([eE][-+]?[0-9]+)?$/', 'number_comma_decimal', NULL, 0),
('number_1dp_comma_decimal',  'Number (1 decimal place - comma as decimal)',  '/^-?\\d+,\\d$/',  '/^-?\\d+,\\d$/',  'number_comma_decimal', NULL ,  '0'),
('number_2dp_comma_decimal',  'Number (2 decimal places - comma as decimal)',  '/^-?\\d+,\\d{2}$/',  '/^-?\\d+,\\d{2}$/',  'number_comma_decimal', NULL ,  '0'),
('number_3dp_comma_decimal',  'Number (3 decimal places - comma as decimal)',  '/^-?\\d+,\\d{3}$/',  '/^-?\\d+,\\d{3}$/',  'number_comma_decimal', NULL ,  '0'),
('number_4dp_comma_decimal',  'Number (4 decimal places - comma as decimal)',  '/^-?\\d+,\\d{4}$/',  '/^-?\\d+,\\d{4}$/',  'number_comma_decimal', NULL ,  '0');

INSERT INTO redcap_surveys_themes (theme_name, ui_id, theme_text_buttons, theme_bg_page, theme_text_title, theme_bg_title, theme_text_sectionheader, theme_bg_sectionheader, theme_text_question, theme_bg_question) VALUES
('Flat White', NULL, '000000', 'eeeeee', '000000', 'FFFFFF', 'FFFFFF', '444444', '000000', 'FFFFFF'),
('Slate and Khaki', NULL, '000000', 'EBE8D9', '000000', 'c5d5cb', 'FFFFFF', '909A94', '000000', 'f3f3f3'),
('Colorful Pastel', NULL, '000', 'f1fafc', '274e13', 'e9f1e3', '660000', 'F6C2C2', '660000', 'f7f8d7'),
('Blue Skies', NULL, '0C74A9', 'cfe2f3', '0b5394', 'FFFFFF', 'FFFFFF', '0b5394', '0b5394', 'ffffff'),
('Cappucino', NULL, '7d4627', '783f04', '7d4627', 'fff', 'FFFFFF', 'b18b64', '783f04', 'fce5cd'),
('Red Brick', NULL, '000000', '660000', 'ffffff', '990000', 'ffffff', '000000', '000000', 'ffffff'),
('Grayscale', NULL, '30231d', '000000', 'ffffff', '666666', 'ffffff', '444444', '000000', 'eeeeee'),
('Plum', NULL, '000000', '351c75', '000000', 'd9d2e9', 'FFFFFF', '8e7cc3', '000000', 'd9d2e9'),
('Forest Green', NULL, '7f6000', '274e13', 'ffffff', '6aa84f', 'ffffff', '38761d', '7f6000', 'd9ead3'),
('Sunny Day', NULL, 'B2400E', 'FFFF80', 'B2400E', 'FFFFFF', 'FFFFFF', 'f67719', 'b85b16', 'FEFFD3');

-- Add custom site configuration values --
UPDATE redcap_config SET value = 'sha512' WHERE field_name = 'password_algo';
UPDATE redcap_config SET value = '' WHERE field_name = 'redcap_csrf_token';
UPDATE redcap_config SET value = '0' WHERE field_name = 'superusers_only_create_project';
UPDATE redcap_config SET value = '1' WHERE field_name = 'superusers_only_move_to_prod';
UPDATE redcap_config SET value = '1' WHERE field_name = 'auto_report_stats';
UPDATE redcap_config SET value = '' WHERE field_name = 'bioportal_api_token';
UPDATE redcap_config SET value = 'http://127.0.0.1:1130/redcap/' WHERE field_name = 'redcap_base_url';
UPDATE redcap_config SET value = '1' WHERE field_name = 'enable_url_shortener';
UPDATE redcap_config SET value = 'D/M/Y_12' WHERE field_name = 'default_datetime_format';
UPDATE redcap_config SET value = ',' WHERE field_name = 'default_number_format_decimal';
UPDATE redcap_config SET value = '.' WHERE field_name = 'default_number_format_thousands_sep';
UPDATE redcap_config SET value = 'REDCap Administrator (123-456-7890)' WHERE field_name = 'homepage_contact';
UPDATE redcap_config SET value = 'email@yoursite.edu' WHERE field_name = 'homepage_contact_email';
UPDATE redcap_config SET value = 'REDCap Administrator (123-456-7890)' WHERE field_name = 'project_contact_name';
UPDATE redcap_config SET value = 'email@yoursite.edu' WHERE field_name = 'project_contact_email';
UPDATE redcap_config SET value = 'SoAndSo University' WHERE field_name = 'institution';
UPDATE redcap_config SET value = 'SoAndSo Institute for Clinical and Translational Research' WHERE field_name = 'site_org_type';
UPDATE redcap_config SET value = '/var/www/html/redcap/hook_functions.php' WHERE field_name = 'hook_functions_file';
UPDATE redcap_config SET value = '6.14.0' WHERE field_name = 'redcap_version';

-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Classic Database';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`, `data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`, `calendar`, `data_entry`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_metadata --

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'study_id', NULL, 'demographics', 'Demographics', 1, NULL, NULL, 'text', 'Study ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_enrolled', NULL, 'demographics', NULL, 2, NULL, 'Consent Information', 'text', 'Date subject signed consent', NULL, 'YYYY-MM-DD', 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'patient_document', NULL, 'demographics', NULL, 2.1, NULL, NULL, 'file', 'Upload the patient''s consent form', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'demographics', NULL, 3, NULL, 'Contact Information', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'demographics', NULL, 4, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'address', '1', 'demographics', NULL, 5, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'telephone_1', '1', 'demographics', NULL, 6, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'email', '1', 'demographics', NULL, 8, NULL, NULL, 'text', 'E-mail', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dob', '1', 'demographics', NULL, 8.1, NULL, NULL, 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'age', NULL, 'demographics', NULL, 8.2, NULL, NULL, 'calc', 'Age (years)', 'rounddown(datediff([dob],''today'',''y''))', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'demographics', NULL, 9, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'race', NULL, 'demographics', NULL, 10, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'demographics', NULL, 11, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'given_birth', NULL, 'demographics', NULL, 12, NULL, NULL, 'yesno', 'Has the patient given birth before?', NULL, NULL, NULL, NULL, NULL, NULL, '[sex] = "0"', 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'num_children', NULL, 'demographics', NULL, 13, NULL, NULL, 'text', 'How many times has the patient given birth?', NULL, NULL, 'int', '0', NULL, 'soft_typed', '[sex] = "0" and [given_birth] = "1"', 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'gym', NULL, 'demographics', NULL, 14, NULL, 'Please provide the patient''s weekly schedule for the activities below.', 'checkbox', 'Gym (Weight Training)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'aerobics', NULL, 'demographics', NULL, 15, NULL, NULL, 'checkbox', 'Aerobics', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'eat', NULL, 'demographics', NULL, 16, NULL, NULL, 'checkbox', 'Eat Out (Dinner/Lunch)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'drink', NULL, 'demographics', NULL, 17, NULL, NULL, 'checkbox', 'Drink (Alcoholic Beverages)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'specify_mood', NULL, 'demographics', NULL, 17.1, NULL, 'Other information', 'slider', 'Specify the patient''s mood', 'Very sad | Indifferent | Very happy', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'meds', NULL, 'demographics', NULL, 17.3, NULL, NULL, 'checkbox', 'Is patient taking any of the following medications? (check all that apply)', '1, Lexapro \\n 2, Celexa \\n 3, Prozac \\n 4, Paxil \\n 5, Zoloft', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'demographics', NULL, 19, 'cm', NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'demographics', NULL, 20, 'kilograms', NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi', NULL, 'demographics', NULL, 21, 'kilograms', NULL, 'calc', 'BMI', 'round(([weight]*10000)/(([height])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'comments', NULL, 'demographics', NULL, 22, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'demographics_complete', NULL, 'demographics', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_b', NULL, 'baseline_data', 'Baseline Data', 24, NULL, 'Baseline Measurements', 'text', 'Date of baseline visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_blood_b', NULL, 'baseline_data', NULL, 25, NULL, NULL, 'text', 'Date blood was drawn', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_b', NULL, 'baseline_data', NULL, 26, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'int', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_b', NULL, 'baseline_data', NULL, 27, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_b', NULL, 'baseline_data', NULL, 28, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_b', NULL, 'baseline_data', NULL, 29, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_b', NULL, 'baseline_data', NULL, 30, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_b', NULL, 'baseline_data', NULL, 31, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_b', NULL, 'baseline_data', NULL, 32, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_b', NULL, 'baseline_data', NULL, 33, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma1_b', NULL, 'baseline_data', NULL, 34, NULL, NULL, 'select', 'Collected Plasma 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma2_b', NULL, 'baseline_data', NULL, 35, NULL, NULL, 'select', 'Collected Plasma 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma3_b', NULL, 'baseline_data', NULL, 36, NULL, NULL, 'select', 'Collected Plasma 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum1_b', NULL, 'baseline_data', NULL, 37, NULL, NULL, 'select', 'Collected Serum 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum2_b', NULL, 'baseline_data', NULL, 38, NULL, NULL, 'select', 'Collected Serum 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum3_b', NULL, 'baseline_data', NULL, 39, NULL, NULL, 'select', 'Collected Serum 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sga_b', NULL, 'baseline_data', NULL, 40, NULL, NULL, 'text', 'Subject Global Assessment (score = 1-7)', NULL, NULL, 'float', '0.9', '7.1', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_supplement_dispensed', NULL, 'baseline_data', NULL, 41, NULL, NULL, 'text', 'Date patient begins supplement', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'baseline_data_complete', NULL, 'baseline_data', NULL, 42, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_1', NULL, 'month_1_data', 'Month 1 Data', 43, NULL, 'Month 1', 'text', 'Date of Month 1 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_1', NULL, 'month_1_data', NULL, 44, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_1', NULL, 'month_1_data', NULL, 45, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_1', NULL, 'month_1_data', NULL, 46, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_1', NULL, 'month_1_data', NULL, 47, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_1', NULL, 'month_1_data', NULL, 48, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_1', NULL, 'month_1_data', NULL, 49, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_1', NULL, 'month_1_data', NULL, 50, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_1', NULL, 'month_1_data', NULL, 51, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_1', NULL, 'month_1_data', NULL, 52, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_1', NULL, 'month_1_data', NULL, 53, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_1', NULL, 'month_1_data', NULL, 54, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_1', NULL, 'month_1_data', NULL, 55, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_1', NULL, 'month_1_data', NULL, 56, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_1', NULL, 'month_1_data', NULL, 57, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_1', NULL, 'month_1_data', NULL, 58, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_1', NULL, 'month_1_data', NULL, 59, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_1', NULL, 'month_1_data', NULL, 60, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_1', NULL, 'month_1_data', NULL, 61, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_1_data_complete', NULL, 'month_1_data', NULL, 62, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_2', NULL, 'month_2_data', 'Month 2 Data', 63, NULL, 'Month 2', 'text', 'Date of Month 2 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_2', NULL, 'month_2_data', NULL, 64, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_2', NULL, 'month_2_data', NULL, 65, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_2', NULL, 'month_2_data', NULL, 66, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_2', NULL, 'month_2_data', NULL, 67, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_2', NULL, 'month_2_data', NULL, 68, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_2', NULL, 'month_2_data', NULL, 69, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_2', NULL, 'month_2_data', NULL, 70, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_2', NULL, 'month_2_data', NULL, 71, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_2', NULL, 'month_2_data', NULL, 72, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_2', NULL, 'month_2_data', NULL, 73, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_2', NULL, 'month_2_data', NULL, 74, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_2', NULL, 'month_2_data', NULL, 75, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_2', NULL, 'month_2_data', NULL, 76, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_2', NULL, 'month_2_data', NULL, 77, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_2', NULL, 'month_2_data', NULL, 78, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_2', NULL, 'month_2_data', NULL, 79, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_2', NULL, 'month_2_data', NULL, 80, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_2', NULL, 'month_2_data', NULL, 81, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_2_data_complete', NULL, 'month_2_data', NULL, 82, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_3', NULL, 'month_3_data', 'Month 3 Data', 83, NULL, 'Month 3', 'text', 'Date of Month 3 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_blood_3', NULL, 'month_3_data', NULL, 84, NULL, NULL, 'text', 'Date blood was drawn', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_3', NULL, 'month_3_data', NULL, 85, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_3', NULL, 'month_3_data', NULL, 86, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_3', NULL, 'month_3_data', NULL, 87, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_3', NULL, 'month_3_data', NULL, 88, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_3', NULL, 'month_3_data', NULL, 89, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_3', NULL, 'month_3_data', NULL, 90, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_3', NULL, 'month_3_data', NULL, 91, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_3', NULL, 'month_3_data', NULL, 92, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma1_3', NULL, 'month_3_data', NULL, 93, NULL, NULL, 'select', 'Collected Plasma 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma2_3', NULL, 'month_3_data', NULL, 94, NULL, NULL, 'select', 'Collected Plasma 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma3_3', NULL, 'month_3_data', NULL, 95, NULL, NULL, 'select', 'Collected Plasma 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum1_3', NULL, 'month_3_data', NULL, 96, NULL, NULL, 'select', 'Collected Serum 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum2_3', NULL, 'month_3_data', NULL, 97, NULL, NULL, 'select', 'Collected Serum 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum3_3', NULL, 'month_3_data', NULL, 98, NULL, NULL, 'select', 'Collected Serum 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sga_3', NULL, 'month_3_data', NULL, 99, NULL, NULL, 'text', 'Subject Global Assessment (score = 1-7)', NULL, NULL, 'float', '0.9', '7.1', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_3', NULL, 'month_3_data', NULL, 100, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_3', NULL, 'month_3_data', NULL, 101, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_3', NULL, 'month_3_data', NULL, 102, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_3', NULL, 'month_3_data', NULL, 103, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_3', NULL, 'month_3_data', NULL, 104, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_3', NULL, 'month_3_data', NULL, 105, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_3', NULL, 'month_3_data', NULL, 106, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_3', NULL, 'month_3_data', NULL, 107, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_3', NULL, 'month_3_data', NULL, 108, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_3', NULL, 'month_3_data', NULL, 109, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_3_data_complete', NULL, 'month_3_data', NULL, 110, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', 'Completion Data', 111, NULL, 'Study Completion Information', 'select', 'Has patient completed study?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 112, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 113, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study_date', NULL, 'completion_data', NULL, 114, NULL, NULL, 'text', 'Date of study completion', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', NULL, 115, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 116, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains six data entry forms, including forms for demography and baseline data, three monthly data forms, and concludes with a completion data form.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Longitudinal Database (1 arm)';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, repeatforms, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO redcap_user_rights (project_id, username, expiration, group_id, lock_record, data_export_tool, data_import_tool, data_comparison_tool, data_logging, file_repository, double_data, user_rights, data_access_groups, graphical, reports, design, calendar, data_entry, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1);
-- Create arms --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES(@project_id, 1, 'Drug A');
set @arm_id1 = LAST_INSERT_ID();
-- Create events --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 0, 0, 0, 'Enrollment');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'baseline_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'demographics');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 1, 0, 0, 'Dose 1');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 3, 0, 0, 'Visit 1');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 8, 0, 0, 'Dose 2');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 10, 0, 0, 'Visit 2');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 15, 0, 0, 'Dose 3');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 17, 0, 0, 'Visit 3');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 30, 0, 0, 'Final visit');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_project_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
-- Insert into redcap_metadata --

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'study_id', NULL, 'demographics', 'Demographics', 1, NULL, NULL, 'text', 'Study ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_enrolled', NULL, 'demographics', NULL, 2, NULL, 'Consent Information', 'text', 'Date subject signed consent', NULL, 'YYYY-MM-DD', 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'patient_document', NULL, 'demographics', NULL, 2.1, NULL, NULL, 'file', 'Upload the patient''s consent form', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'demographics', NULL, 3, NULL, 'Contact Information', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'demographics', NULL, 4, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'address', '1', 'demographics', NULL, 5, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'telephone_1', '1', 'demographics', NULL, 6, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'email', '1', 'demographics', NULL, 8, NULL, NULL, 'text', 'E-mail', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dob', '1', 'demographics', NULL, 8.1, NULL, NULL, 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'age', NULL, 'demographics', NULL, 8.2, NULL, NULL, 'calc', 'Age (years)', 'rounddown(datediff([dob],''today'',''y''))', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'demographics', NULL, 9, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'race', NULL, 'demographics', NULL, 10, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'demographics', NULL, 11, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'given_birth', NULL, 'demographics', NULL, 12, NULL, NULL, 'yesno', 'Has the patient given birth before?', NULL, NULL, NULL, NULL, NULL, NULL, '[sex] = "0"', 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'num_children', NULL, 'demographics', NULL, 13, NULL, NULL, 'text', 'How many times has the patient given birth?', NULL, NULL, 'int', '0', NULL, 'soft_typed', '[sex] = "0" and [given_birth] = "1"', 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'gym', NULL, 'demographics', NULL, 14, NULL, 'Please provide the patient''s weekly schedule for the activities below.', 'checkbox', 'Gym (Weight Training)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'aerobics', NULL, 'demographics', NULL, 15, NULL, NULL, 'checkbox', 'Aerobics', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'eat', NULL, 'demographics', NULL, 16, NULL, NULL, 'checkbox', 'Eat Out (Dinner/Lunch)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'drink', NULL, 'demographics', NULL, 17, NULL, NULL, 'checkbox', 'Drink (Alcoholic Beverages)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'specify_mood', NULL, 'demographics', NULL, 17.1, NULL, 'Other information', 'slider', 'Specify the patient''s mood', 'Very sad | Indifferent | Very happy', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'meds', NULL, 'demographics', NULL, 17.3, NULL, NULL, 'checkbox', 'Is patient taking any of the following medications? (check all that apply)', '1, Lexapro \\n 2, Celexa \\n 3, Prozac \\n 4, Paxil \\n 5, Zoloft', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'demographics', NULL, 19, 'cm', NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'demographics', NULL, 20, 'kilograms', NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi', NULL, 'demographics', NULL, 21, 'kilograms', NULL, 'calc', 'BMI', 'round(([weight]*10000)/(([height])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'comments', NULL, 'demographics', NULL, 22, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'demographics_complete', NULL, 'demographics', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height2', NULL, 'baseline_data', 'Baseline Data', 31, NULL, NULL, 'text', 'Height (cm)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight2', NULL, 'baseline_data', NULL, 32, NULL, NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi2', NULL, 'baseline_data', NULL, 33, NULL, NULL, 'calc', 'BMI', 'round(([weight2]*10000)/(([height2])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_b', NULL, 'baseline_data', NULL, 34, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_b', NULL, 'baseline_data', NULL, 35, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_b', NULL, 'baseline_data', NULL, 36, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_b', NULL, 'baseline_data', NULL, 37, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_b', NULL, 'baseline_data', NULL, 38, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'baseline_data_complete', NULL, 'baseline_data', NULL, 39, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld1', NULL, 'visit_lab_data', 'Visit Lab Data', 40, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld2', NULL, 'visit_lab_data', NULL, 41, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld3', NULL, 'visit_lab_data', NULL, 42, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld4', NULL, 'visit_lab_data', NULL, 43, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld5', NULL, 'visit_lab_data', NULL, 44, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_lab_data_complete', NULL, 'visit_lab_data', NULL, 45, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq1', NULL, 'patient_morale_questionnaire', 'Patient Morale Questionnaire', 46, NULL, NULL, 'select', 'On average, how many pills did you take each day last week?', '0, less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq2', NULL, 'patient_morale_questionnaire', NULL, 47, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq3', NULL, 'patient_morale_questionnaire', NULL, 48, NULL, NULL, 'radio', 'Would you be willing to discuss your experiences with a psychiatrist?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq4', NULL, 'patient_morale_questionnaire', NULL, 49, NULL, NULL, 'select', 'How open are you to further testing?', '0, not open \\n 1, undecided \\n 2, very open', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'patient_morale_questionnaire_complete', NULL, 'patient_morale_questionnaire', NULL, 50, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw1', NULL, 'visit_blood_workup', 'Visit Blood Workup', 51, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw2', NULL, 'visit_blood_workup', NULL, 52, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw3', NULL, 'visit_blood_workup', NULL, 53, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw4', NULL, 'visit_blood_workup', NULL, 54, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw5', NULL, 'visit_blood_workup', NULL, 55, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw6', NULL, 'visit_blood_workup', NULL, 56, NULL, NULL, 'radio', 'Blood draw shift?', '0, AM \\n 1, PM', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw7', NULL, 'visit_blood_workup', NULL, 57, NULL, NULL, 'radio', 'Blood draw by', '0, RN \\n 1, LPN \\n 2, nurse assistant \\n 3, doctor', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw8', NULL, 'visit_blood_workup', NULL, 58, NULL, NULL, 'select', 'Level of patient anxiety', '0, not anxious \\n 1, undecided \\n 2, very anxious', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw9', NULL, 'visit_blood_workup', NULL, 59, NULL, NULL, 'select', 'Patient scheduled for future draws?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_blood_workup_complete', NULL, 'visit_blood_workup', NULL, 60, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob1', NULL, 'visit_observed_behavior', 'Visit Observed Behavior', 61, NULL, 'Was the patient...', 'radio', 'nervous?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob2', NULL, 'visit_observed_behavior', NULL, 62, NULL, NULL, 'radio', 'worried?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob3', NULL, 'visit_observed_behavior', NULL, 63, NULL, NULL, 'radio', 'scared?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob4', NULL, 'visit_observed_behavior', NULL, 64, NULL, NULL, 'radio', 'fidgety?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob5', NULL, 'visit_observed_behavior', NULL, 65, NULL, NULL, 'radio', 'crying?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob6', NULL, 'visit_observed_behavior', NULL, 66, NULL, NULL, 'radio', 'screaming?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob7', NULL, 'visit_observed_behavior', NULL, 67, NULL, NULL, 'textarea', 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob8', NULL, 'visit_observed_behavior', NULL, 68, NULL, 'Were you...', 'radio', 'nervous?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob9', NULL, 'visit_observed_behavior', NULL, 69, NULL, NULL, 'radio', 'worried?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob10', NULL, 'visit_observed_behavior', NULL, 70, NULL, NULL, 'radio', 'scared?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob11', NULL, 'visit_observed_behavior', NULL, 71, NULL, NULL, 'radio', 'fidgety?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob12', NULL, 'visit_observed_behavior', NULL, 72, NULL, NULL, 'radio', 'crying?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob13', NULL, 'visit_observed_behavior', NULL, 73, NULL, NULL, 'radio', 'screaming?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob14', NULL, 'visit_observed_behavior', NULL, 74, NULL, NULL, 'textarea', 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_observed_behavior_complete', NULL, 'visit_observed_behavior', NULL, 75, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', 'Completion Data', 76, NULL, NULL, 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', NULL, 77, NULL, NULL, 'select', 'Has patient completed study?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 78, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_4', NULL, 'completion_data', NULL, 79, NULL, NULL, 'text', 'Date of last visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_4', NULL, 'completion_data', NULL, 80, NULL, NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_4', NULL, 'completion_data', NULL, 81, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_4', NULL, 'completion_data', NULL, 82, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_4', NULL, 'completion_data', NULL, 83, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_4', NULL, 'completion_data', NULL, 84, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_4', NULL, 'completion_data', NULL, 85, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_4', NULL, 'completion_data', NULL, 86, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 87, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 88, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq1', NULL, 'completion_project_questionnaire', 'Completion Project Questionnaire', 89, NULL, NULL, 'text', 'Date of study completion', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq2', NULL, 'completion_project_questionnaire', NULL, 90, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq3', NULL, 'completion_project_questionnaire', NULL, 91, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq4', NULL, 'completion_project_questionnaire', NULL, 92, NULL, NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq5', NULL, 'completion_project_questionnaire', NULL, 93, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq6', NULL, 'completion_project_questionnaire', NULL, 94, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq7', NULL, 'completion_project_questionnaire', NULL, 95, NULL, NULL, 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq8', NULL, 'completion_project_questionnaire', NULL, 96, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq9', NULL, 'completion_project_questionnaire', NULL, 97, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq10', NULL, 'completion_project_questionnaire', NULL, 98, NULL, NULL, 'select', 'On average, how many pills did you take each day last week?', '0, less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq11', NULL, 'completion_project_questionnaire', NULL, 99, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq12', NULL, 'completion_project_questionnaire', NULL, 100, NULL, NULL, 'radio', 'Would you be willing to discuss your experiences with a psychiatrist?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq13', NULL, 'completion_project_questionnaire', NULL, 101, NULL, NULL, 'select', 'How open are you to further testing?', '0, not open \\n 1, undecided \\n 2, very open', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_project_questionnaire_complete', NULL, 'completion_project_questionnaire', NULL, 102, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains nine data entry forms (beginning with a demography form) for collecting data longitudinally over eight different events.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Longitudinal Database (2 arms)';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, repeatforms, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO redcap_user_rights (project_id, username, expiration, group_id, lock_record, data_export_tool, data_import_tool, data_comparison_tool, data_logging, file_repository, double_data, user_rights, data_access_groups, graphical, reports, design, calendar, data_entry, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1);
-- Create arms --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES(@project_id, 1, 'Drug A');
set @arm_id1 = LAST_INSERT_ID();
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES(@project_id, 2, 'Drug B');
set @arm_id2 = LAST_INSERT_ID();
-- Create events --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 0, 0, 0, 'Enrollment');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'baseline_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'demographics');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 1, 0, 0, 'Dose 1');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 3, 0, 0, 'Visit 1');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 8, 0, 0, 'Dose 2');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 10, 0, 0, 'Visit 2');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 15, 0, 0, 'Dose 3');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 17, 0, 0, 'Visit 3');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id1, 30, 0, 0, 'Final visit');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_project_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 0, 0, 0, 'Enrollment');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'baseline_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'demographics');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 5, 0, 0, 'Deadline to opt out of study');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 7, 0, 0, 'First dose');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 10, 2, 2, 'First visit');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 13, 0, 0, 'Second dose');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 15, 2, 2, 'Second visit');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 20, 2, 2, 'Final visit');
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_project_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'patient_morale_questionnaire');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_blood_workup');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_lab_data');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'visit_observed_behavior');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES(@arm_id2, 30, 0, 0, 'Deadline to return feedback');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_metadata --

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'study_id', NULL, 'demographics', 'Demographics', 1, NULL, NULL, 'text', 'Study ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_enrolled', NULL, 'demographics', NULL, 2, NULL, 'Consent Information', 'text', 'Date subject signed consent', NULL, 'YYYY-MM-DD', 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'patient_document', NULL, 'demographics', NULL, 2.1, NULL, NULL, 'file', 'Upload the patient''s consent form', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'demographics', NULL, 3, NULL, 'Contact Information', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'demographics', NULL, 4, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'address', '1', 'demographics', NULL, 5, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'telephone_1', '1', 'demographics', NULL, 6, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'email', '1', 'demographics', NULL, 8, NULL, NULL, 'text', 'E-mail', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dob', '1', 'demographics', NULL, 8.1, NULL, NULL, 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'age', NULL, 'demographics', NULL, 8.2, NULL, NULL, 'calc', 'Age (years)', 'rounddown(datediff([dob],''today'',''y''))', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'demographics', NULL, 9, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'race', NULL, 'demographics', NULL, 10, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'demographics', NULL, 11, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'given_birth', NULL, 'demographics', NULL, 12, NULL, NULL, 'yesno', 'Has the patient given birth before?', NULL, NULL, NULL, NULL, NULL, NULL, '[sex] = "0"', 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'num_children', NULL, 'demographics', NULL, 13, NULL, NULL, 'text', 'How many times has the patient given birth?', NULL, NULL, 'int', '0', NULL, 'soft_typed', '[sex] = "0" and [given_birth] = "1"', 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'gym', NULL, 'demographics', NULL, 14, NULL, 'Please provide the patient''s weekly schedule for the activities below.', 'checkbox', 'Gym (Weight Training)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'aerobics', NULL, 'demographics', NULL, 15, NULL, NULL, 'checkbox', 'Aerobics', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'eat', NULL, 'demographics', NULL, 16, NULL, NULL, 'checkbox', 'Eat Out (Dinner/Lunch)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'drink', NULL, 'demographics', NULL, 17, NULL, NULL, 'checkbox', 'Drink (Alcoholic Beverages)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'specify_mood', NULL, 'demographics', NULL, 17.1, NULL, 'Other information', 'slider', 'Specify the patient''s mood', 'Very sad | Indifferent | Very happy', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'meds', NULL, 'demographics', NULL, 17.3, NULL, NULL, 'checkbox', 'Is patient taking any of the following medications? (check all that apply)', '1, Lexapro \\n 2, Celexa \\n 3, Prozac \\n 4, Paxil \\n 5, Zoloft', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'demographics', NULL, 19, 'cm', NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'demographics', NULL, 20, 'kilograms', NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi', NULL, 'demographics', NULL, 21, 'kilograms', NULL, 'calc', 'BMI', 'round(([weight]*10000)/(([height])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'comments', NULL, 'demographics', NULL, 22, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'demographics_complete', NULL, 'demographics', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height2', NULL, 'baseline_data', 'Baseline Data', 31, NULL, NULL, 'text', 'Height (cm)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight2', NULL, 'baseline_data', NULL, 32, NULL, NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi2', NULL, 'baseline_data', NULL, 33, NULL, NULL, 'calc', 'BMI', 'round(([weight2]*10000)/(([height2])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_b', NULL, 'baseline_data', NULL, 34, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_b', NULL, 'baseline_data', NULL, 35, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_b', NULL, 'baseline_data', NULL, 36, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_b', NULL, 'baseline_data', NULL, 37, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_b', NULL, 'baseline_data', NULL, 38, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'baseline_data_complete', NULL, 'baseline_data', NULL, 39, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld1', NULL, 'visit_lab_data', 'Visit Lab Data', 40, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld2', NULL, 'visit_lab_data', NULL, 41, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld3', NULL, 'visit_lab_data', NULL, 42, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld4', NULL, 'visit_lab_data', NULL, 43, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vld5', NULL, 'visit_lab_data', NULL, 44, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_lab_data_complete', NULL, 'visit_lab_data', NULL, 45, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq1', NULL, 'patient_morale_questionnaire', 'Patient Morale Questionnaire', 46, NULL, NULL, 'select', 'On average, how many pills did you take each day last week?', '0, less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq2', NULL, 'patient_morale_questionnaire', NULL, 47, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq3', NULL, 'patient_morale_questionnaire', NULL, 48, NULL, NULL, 'radio', 'Would you be willing to discuss your experiences with a psychiatrist?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'pmq4', NULL, 'patient_morale_questionnaire', NULL, 49, NULL, NULL, 'select', 'How open are you to further testing?', '0, not open \\n 1, undecided \\n 2, very open', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'patient_morale_questionnaire_complete', NULL, 'patient_morale_questionnaire', NULL, 50, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw1', NULL, 'visit_blood_workup', 'Visit Blood Workup', 51, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw2', NULL, 'visit_blood_workup', NULL, 52, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw3', NULL, 'visit_blood_workup', NULL, 53, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw4', NULL, 'visit_blood_workup', NULL, 54, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw5', NULL, 'visit_blood_workup', NULL, 55, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw6', NULL, 'visit_blood_workup', NULL, 56, NULL, NULL, 'radio', 'Blood draw shift?', '0, AM \\n 1, PM', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw7', NULL, 'visit_blood_workup', NULL, 57, NULL, NULL, 'radio', 'Blood draw by', '0, RN \\n 1, LPN \\n 2, nurse assistant \\n 3, doctor', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw8', NULL, 'visit_blood_workup', NULL, 58, NULL, NULL, 'select', 'Level of patient anxiety', '0, not anxious \\n 1, undecided \\n 2, very anxious', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vbw9', NULL, 'visit_blood_workup', NULL, 59, NULL, NULL, 'select', 'Patient scheduled for future draws?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_blood_workup_complete', NULL, 'visit_blood_workup', NULL, 60, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob1', NULL, 'visit_observed_behavior', 'Visit Observed Behavior', 61, NULL, 'Was the patient...', 'radio', 'nervous?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob2', NULL, 'visit_observed_behavior', NULL, 62, NULL, NULL, 'radio', 'worried?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob3', NULL, 'visit_observed_behavior', NULL, 63, NULL, NULL, 'radio', 'scared?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob4', NULL, 'visit_observed_behavior', NULL, 64, NULL, NULL, 'radio', 'fidgety?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob5', NULL, 'visit_observed_behavior', NULL, 65, NULL, NULL, 'radio', 'crying?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob6', NULL, 'visit_observed_behavior', NULL, 66, NULL, NULL, 'radio', 'screaming?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob7', NULL, 'visit_observed_behavior', NULL, 67, NULL, NULL, 'textarea', 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob8', NULL, 'visit_observed_behavior', NULL, 68, NULL, 'Were you...', 'radio', 'nervous?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob9', NULL, 'visit_observed_behavior', NULL, 69, NULL, NULL, 'radio', 'worried?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob10', NULL, 'visit_observed_behavior', NULL, 70, NULL, NULL, 'radio', 'scared?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob11', NULL, 'visit_observed_behavior', NULL, 71, NULL, NULL, 'radio', 'fidgety?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob12', NULL, 'visit_observed_behavior', NULL, 72, NULL, NULL, 'radio', 'crying?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob13', NULL, 'visit_observed_behavior', NULL, 73, NULL, NULL, 'radio', 'screaming?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'vob14', NULL, 'visit_observed_behavior', NULL, 74, NULL, NULL, 'textarea', 'other', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'visit_observed_behavior_complete', NULL, 'visit_observed_behavior', NULL, 75, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', 'Completion Data', 76, NULL, NULL, 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', NULL, 77, NULL, NULL, 'select', 'Has patient completed study?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 78, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_4', NULL, 'completion_data', NULL, 79, NULL, NULL, 'text', 'Date of last visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_4', NULL, 'completion_data', NULL, 80, NULL, NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_4', NULL, 'completion_data', NULL, 81, NULL, NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_4', NULL, 'completion_data', NULL, 82, NULL, NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_4', NULL, 'completion_data', NULL, 83, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_4', NULL, 'completion_data', NULL, 84, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_4', NULL, 'completion_data', NULL, 85, NULL, NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_4', NULL, 'completion_data', NULL, 86, NULL, NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 87, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 88, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq1', NULL, 'completion_project_questionnaire', 'Completion Project Questionnaire', 89, NULL, NULL, 'text', 'Date of study completion', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq2', NULL, 'completion_project_questionnaire', NULL, 90, NULL, NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq3', NULL, 'completion_project_questionnaire', NULL, 91, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq4', NULL, 'completion_project_questionnaire', NULL, 92, NULL, NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq5', NULL, 'completion_project_questionnaire', NULL, 93, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq6', NULL, 'completion_project_questionnaire', NULL, 94, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq7', NULL, 'completion_project_questionnaire', NULL, 95, NULL, NULL, 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq8', NULL, 'completion_project_questionnaire', NULL, 96, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq9', NULL, 'completion_project_questionnaire', NULL, 97, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq10', NULL, 'completion_project_questionnaire', NULL, 98, NULL, NULL, 'select', 'On average, how many pills did you take each day last week?', '0, less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq11', NULL, 'completion_project_questionnaire', NULL, 99, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq12', NULL, 'completion_project_questionnaire', NULL, 100, NULL, NULL, 'radio', 'Would you be willing to discuss your experiences with a psychiatrist?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cpq13', NULL, 'completion_project_questionnaire', NULL, 101, NULL, NULL, 'select', 'How open are you to further testing?', '0, not open \\n 1, undecided \\n 2, very open', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_project_questionnaire_complete', NULL, 'completion_project_questionnaire', NULL, 102, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains nine data entry forms (beginning with a demography form) for collecting data on two different arms (Drug A and Drug B) with each arm containing eight different events.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Single Survey';
-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, surveys_enabled, auto_inc_set, display_project_logo_institution) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 1, 1, 0);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`,
`data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`,
`calendar`, `data_entry`, `participants`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 0, 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_surveys
INSERT INTO redcap_surveys (project_id, form_name, title, instructions, acknowledgement, question_by_section, question_auto_numbering, survey_enabled, save_and_return, logo, hide_title) VALUES
(@project_id, 'survey', 'Example Survey', '<p style="margin-top: 10px; margin-right: 0px; margin-bottom: 10px; margin-left: 0px; font-family: Arial, Verdana, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 1.5em; max-width: 700px; clear: both; padding: 0px;">These are your survey instructions that you would enter for your survey participants. You may put whatever text you like here, which may include information about the purpose of the survey, who is taking the survey, or how to take the survey.</p><br><p style="margin-top: 10px; margin-right: 0px; margin-bottom: 10px; margin-left: 0px; font-family: Arial, Verdana, Helvetica, sans-serif; font-size: 12px; text-align: left; line-height: 1.5em; max-width: 700px; clear: both; padding: 0px;">Surveys can use a single survey link for all respondents, which can be posted on a webpage or emailed out from your email application of choice. <strong>By default, all survey responses are collected anonymously</strong> (that is, unless your survey asks for name, email, or other identifying information). If you wish to track individuals who have taken your survey, you may upload a list of email addresses into a Participant List within REDCap, in which you can have REDCap send them an email invitation, which will track if they have taken the survey and when it was taken. This method still collects responses anonymously, but if you wish to identify an individual respondent\'s answers, you may do so by also providing an Identifier in your Participant List. Of course, in that case you may want to inform your respondents in your survey\'s instructions that their responses are not being collected anonymously and can thus be traced back to them.</p>', '<p><strong>Thank you for taking the survey.</strong></p><br><p>Have a nice day!</p>', 0, 0, 1, 1, NULL, 0);
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'participant_id', NULL, 'survey', 'Example Survey', 1, NULL, NULL, 'text', 'Participant ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'radio', NULL, 'survey', NULL, 2, NULL, 'Section 1 (This is a section header with descriptive text. It only provides informational text and is used to divide the survey into sections for organization. If the survey is set to be displayed as "one section per page", then these section headers will begin each new page of the survey.)', 'radio', 'You may create MULTIPLE CHOICE questions and set the answer choices for them. You can have as many answer choices as you need. This multiple choice question is rendered as RADIO buttons.', '1, Choice One \\n 2, Choice Two \\n 3, Choice Three \\n 4, Etc.', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dropdown', NULL, 'survey', NULL, 3, NULL, NULL, 'select', 'You may also set multiple choice questions as DROP-DOWN MENUs.', '1, Choice One \\n 2, Choice Two \\n 3, Choice Three \\n 4, Etc.', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'textbox', NULL, 'survey', NULL, 4, NULL, NULL, 'text', 'This is a TEXT BOX, which allows respondents to enter a small amount of text. A Text Box can be validated, if needed, as a number, integer, phone number, email, or zipcode. If validated as a number or integer, you may also set the minimum and/or maximum allowable values.\n\nThis question has "number" validation set with a minimum of 1 and a maximum of 10. ', NULL, NULL, 'float', '1', '10', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ma', NULL, 'survey', NULL, 5, NULL, NULL, 'checkbox', 'This type of multiple choice question, known as CHECKBOXES, allows for more than one answer choice to be selected, whereas radio buttons and drop-downs only allow for one choice.', '1, Choice One \\n 2, Choice Two \\n 3, Choice Three \\n 4, Select as many as you like', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'yn', NULL, 'survey', NULL, 6, NULL, NULL, 'yesno', 'You can create YES-NO questions.<br><br>This question has vertical alignment of choices on the right.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'tf', NULL, 'survey', NULL, 7, NULL, NULL, 'truefalse', 'And you can also create TRUE-FALSE questions.<br><br>This question has horizontal alignment.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'RH', NULL, NULL),
(@project_id, 'date_ymd', NULL, 'survey', NULL, 8, NULL, NULL, 'text', 'DATE questions are also an option. If you click the calendar icon on the right, a pop-up calendar will appear, thus allowing the respondent to easily select a date. Or it can be simply typed in.', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'file', NULL, 'survey', NULL, 9, NULL, NULL, 'file', 'The FILE UPLOAD question type allows respondents to upload any type of document to the survey that you may afterward download and open when viewing your survey results.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'slider', NULL, 'survey', NULL, 10, NULL, NULL, 'slider', 'A SLIDER is a question type that allows the respondent to choose an answer along a continuum. The respondent''s answer is saved as an integer between 0 (far left) and 100 (far right) with a step of 1.', 'You can provide labels above the slider | Middle label | Right-hand label', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'descriptive', NULL, 'survey', NULL, 11, NULL, NULL, 'descriptive', 'You may also use DESCRIPTIVE TEXT to provide informational text within a survey section. ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'gym', NULL, 'survey', NULL, 11.1, NULL, 'Below is a matrix of checkbox fields. A matrix can also be displayed as radio button fields.', 'checkbox', 'Gym (Weight Training)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'aerobics', NULL, 'survey', NULL, 11.2, NULL, NULL, 'checkbox', 'Aerobics', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'eat', NULL, 'survey', NULL, 11.3, NULL, NULL, 'checkbox', 'Eat Out (Dinner/Lunch)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL),
(@project_id, 'drink', NULL, 'survey', NULL, 11.4, NULL, NULL, 'checkbox', 'Drink (Alcoholic Beverages)', '0, Monday \\n 1, Tuesday \\n 2, Wednesday \\n 3, Thursday \\n 4, Friday', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'weekly_schedule', NULL);

INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'radio_branch', NULL, 'survey', NULL, 12, NULL, 'ADVANCED FEATURES: The questions below will illustrate how some advanced survey features are used.', 'radio', 'BRANCHING LOGIC: The question immediately following this one is using branching logic, which means that the question will stay hidden until defined criteria are specified.\n\nFor example, the following question has been set NOT to appear until the respondent selects the second option to the right.  ', '1, This option does nothing. \\n 2, Clicking this option will trigger the branching logic to reveal the next question. \\n 3, This option also does nothing.', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hidden_branch', NULL, 'survey', NULL, 13, NULL, NULL, 'text', 'HIDDEN QUESTION: This question will only appear when you select the second option of the question immediately above.', NULL, NULL, NULL, 'undefined', 'undefined', 'soft_typed', '[radio_branch] = "2"', 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'stop_actions', NULL, 'survey', NULL, 14, NULL, NULL, 'checkbox', 'STOP ACTIONS may be used with any multiple choice question. Stop actions can be applied to any (or all) answer choices. When that answer choice is selected by a respondent, their survey responses are then saved, and the survey is immediately ended.\n\nThe third option to the right has a stop action.', '1, This option does nothing. \\n 2, This option also does nothing. \\n 3, Click here to trigger the stop action and end the survey.', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, '3', NULL),
(@project_id, 'comment_box', NULL, 'survey', NULL, 15, NULL, NULL, 'textarea', 'If you need the respondent to enter a large amount of text, you may use a NOTES BOX.<br><br>This question has also been set as a REQUIRED QUESTION, so the respondent cannot fully submit the survey until this question has been answered. ANY question type can be set to be required.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'survey_complete', NULL, 'survey', NULL, 16, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains a single data collection instrument enabled as a survey, which contains questions to demonstrate all the different field types.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Basic Demography';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`, `data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`, `calendar`, `data_entry`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'record_id', NULL, 'demographics', 'Basic Demography Form', 1, NULL, NULL, 'text', 'Study ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'demographics', NULL, 3, NULL, 'Contact Information', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'demographics', NULL, 4, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'address', '1', 'demographics', NULL, 5, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'telephone', '1', 'demographics', NULL, 6, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'email', '1', 'demographics', NULL, 8, NULL, NULL, 'text', 'E-mail', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dob', '1', 'demographics', NULL, 8.1, NULL, NULL, 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'age', NULL, 'demographics', NULL, 8.2, NULL, NULL, 'calc', 'Age (years)', 'rounddown(datediff([dob],''today'',''y''))', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'demographics', NULL, 9, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'race', NULL, 'demographics', NULL, 10, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'demographics', NULL, 11, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'demographics', NULL, 19, 'cm', NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'demographics', NULL, 20, 'kilograms', NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'bmi', NULL, 'demographics', NULL, 21, 'kilograms', NULL, 'calc', 'BMI', 'round(([weight]*10000)/(([height])^(2)),1)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'comments', NULL, 'demographics', NULL, 22, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'demographics_complete', NULL, 'demographics', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains a single data collection instrument to capture basic demographic information.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Project Tracking Database';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`, `data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`, `calendar`, `data_entry`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'proj_id', NULL, 'project', 'Project', 1, NULL, NULL, 'text', 'Project ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'title', NULL, 'project', NULL, 2, NULL, 'Demographic Characteristics', 'textarea', 'Project Title', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pi_firstname', NULL, 'project', NULL, 3, NULL, NULL, 'text', 'PI First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pi_lastname', NULL, 'project', NULL, 4, NULL, NULL, 'text', 'PI Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pi_vunetid', NULL, 'project', NULL, 5, NULL, NULL, 'text', 'PI VUnetID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'project_type', NULL, 'project', NULL, 6, NULL, NULL, 'select', 'Project Type', '1, Expedited \\n 2, Full Committee \\n 3, Industry only', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'irb_number', NULL, 'project', NULL, 7, NULL, NULL, 'text', 'IRB Number', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'amendment_status', NULL, 'project', NULL, 8, NULL, 'Amendment Information', 'radio', 'Amendment?', '0, No \\n 1, Yes', '', NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'amendment_number', NULL, 'project', NULL, 9, NULL, NULL, 'select', 'Amendment Number', '0 \\n 1 \\n 2 \\n 3 \\n 4 \\n 5 \\n 6 \\n 7 \\n 8 \\n 9 \\n 10 \\n 11 \\n 12 \\n 13 \\n 14 \\n 15 \\n 16 \\n 17 \\n 18 \\n 19 \\n 20', '', NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_type', NULL, 'project', NULL, 10, NULL, 'CRC Legacy System Data', 'select', 'CRC Type', 'A \\n B \\n C \\n D', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_webcamp_import', NULL, 'project', NULL, 11, NULL, NULL, 'select', 'CRC WebCamp Project Import?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_original_review', NULL, 'project', NULL, 12, NULL, NULL, 'select', 'CRC Original Review?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_proposal', NULL, 'project', NULL, 13, NULL, 'Project Files', 'file', 'Research Proposal', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_budget', NULL, 'project', NULL, 14, NULL, NULL, 'file', 'Budget', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_biosketch1', NULL, 'project', NULL, 15, NULL, NULL, 'file', 'Biosketch(1)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_biosketch2', NULL, 'project', NULL, 16, NULL, NULL, 'file', 'Biosketch(2)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_biosketch3', NULL, 'project', NULL, 17, NULL, NULL, 'file', 'Biosketch(3)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_crc', NULL, 'project', NULL, 18, NULL, NULL, 'file', 'CRC Resources', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_other1', NULL, 'project', NULL, 19, NULL, NULL, 'file', 'Other(1)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_other2', NULL, 'project', NULL, 20, NULL, NULL, 'file', 'Other(2)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_other3', NULL, 'project', NULL, 21, NULL, NULL, 'file', 'Other(3)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'project_complete', NULL, 'project', NULL, 22, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_receipt', NULL, 'workflow', 'Workflow', 23, NULL, 'Pre-Pre-Review Information', 'text', 'Project Receipt Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_start_preprereview', NULL, 'workflow', NULL, 24, NULL, NULL, 'text', 'Pre-Pre-Review - Start Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_stop_preprereview', NULL, 'workflow', NULL, 25, NULL, NULL, 'text', 'Pre-Pre-Review - Stop Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'comments_preprereview', NULL, 'workflow', NULL, 26, NULL, NULL, 'textarea', 'Comments - Pre-Pre-Review', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'owner_prepreview', NULL, 'workflow', NULL, 27, NULL, NULL, 'select', 'Owner (Liaison)', '0, Shraddha \\n 1, Jennifer \\n 2, Terri \\n 3, Cheryl \\n 4, Lynda', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_start_prereview', NULL, 'workflow', NULL, 28, NULL, 'Pre-Review Information', 'text', 'Pre-Review Notification Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_stop_prereview', NULL, 'workflow', NULL, 29, NULL, NULL, 'text', 'Pre-Review Completion Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'comments_prereview', NULL, 'workflow', NULL, 30, NULL, NULL, 'textarea', 'Comments - Pre-Review', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_pi_notification', NULL, 'workflow', NULL, 31, NULL, 'PI Notification Information', 'text', 'PI Notification Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_pi_response', NULL, 'workflow', NULL, 32, NULL, NULL, 'text', 'PI Response Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'comments_pi_response', NULL, 'workflow', NULL, 33, NULL, NULL, 'textarea', 'Comments - PI Process', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'file_pi_comments', NULL, 'workflow', NULL, 34, NULL, NULL, 'file', 'PI response', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_agenda', NULL, 'workflow', NULL, 35, NULL, 'Agenda Information', 'text', 'Agenda Date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'rev1_name', NULL, 'workflow', NULL, 36, NULL, NULL, 'text', 'Reviewer 1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'rev2_name', NULL, 'workflow', NULL, 37, NULL, NULL, 'text', 'Reviewer 2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'rev_notification_date', NULL, 'workflow', NULL, 38, NULL, NULL, 'text', 'Date - Sent to Reviewers', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_notification_date', NULL, 'workflow', NULL, 39, NULL, NULL, 'text', 'Date- Sent to SRC', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'status_src_award', NULL, 'workflow', NULL, 40, NULL, NULL, 'select', 'SRC Award Status', '0, Approved \\n 1, Pending \\n 2, Deferred (Studio) \\n 3, Disapproved \\n 4, Tabled \\n 5, Withdrawn', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_priority_score', NULL, 'workflow', NULL, 41, NULL, NULL, 'text', 'SRC Priority Score', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'workflow_complete', NULL, 'workflow', NULL, 42, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_administrative', NULL, 'prereview_administrative', 'Pre-Review Administrative', 43, NULL, NULL, 'select', 'Requires Administrative?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_administrative', NULL, 'prereview_administrative', NULL, 44, NULL, 'Enter PI Pre-Review Notes Or Attach File', 'textarea', 'Notes', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_administrative] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_administrative_doc', NULL, 'prereview_administrative', NULL, 45, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_administrative] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_administrative_date_sent', NULL, 'prereview_administrative', NULL, 46, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_administrative_date_received', NULL, 'prereview_administrative', NULL, 47, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_administrative_complete', NULL, 'prereview_administrative', NULL, 48, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_biostatistics', NULL, 'prereview_biostatistics', 'Pre-Review Biostatistics', 49, NULL, NULL, 'select', 'Requires Biostatistics?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics', NULL, 'prereview_biostatistics', NULL, 50, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_biostatistics] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics_doc', NULL, 'prereview_biostatistics', NULL, 51, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_biostatistics] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics_date_sent', NULL, 'prereview_biostatistics', NULL, 52, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics_date_received', NULL, 'prereview_biostatistics', NULL, 53, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics_hours_awarded', NULL, 'prereview_biostatistics', NULL, 54, NULL, 'Biostatistics Award', 'text', 'Consultation Hours Awarded', NULL, NULL, 'float', '0', '5000', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_biostatistics_complete', NULL, 'prereview_biostatistics', NULL, 55, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_scientific', NULL, 'prereview_scientific', 'Pre-Review Scientific', 56, NULL, NULL, 'select', 'Requires Scientific?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_scientific', NULL, 'prereview_scientific', NULL, 57, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_scientific] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_scientific_doc', NULL, 'prereview_scientific', NULL, 58, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_scientific] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_scientific_date_sent', NULL, 'prereview_scientific', NULL, 59, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_scientific_date_received', NULL, 'prereview_scientific', NULL, 60, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_scientific_complete', NULL, 'prereview_scientific', NULL, 61, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_participant', NULL, 'prereview_participant', 'Pre-Review Participant', 62, NULL, NULL, 'select', 'Requires Participant?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_participant', NULL, 'prereview_participant', NULL, 63, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_participant] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_participant_doc', NULL, 'prereview_participant', NULL, 64, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_participant] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_participant_date_sent', NULL, 'prereview_participant', NULL, 65, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_participant_date_received', NULL, 'prereview_participant', NULL, 66, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_participant_complete', NULL, 'prereview_participant', NULL, 67, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_budget', NULL, 'prereview_budget', 'Pre-Review Budget', 68, NULL, NULL, 'select', 'Requires Budget?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_budget', NULL, 'prereview_budget', NULL, 69, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_budget_doc', NULL, 'prereview_budget', NULL, 70, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_budget] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_budget_date_sent', NULL, 'prereview_budget', NULL, 71, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_budget] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_budget_date_received', NULL, 'prereview_budget', NULL, 72, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_budget_complete', NULL, 'prereview_budget', NULL, 73, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_nursing', NULL, 'prereview_nursing', 'Pre-Review Nursing', 74, NULL, NULL, 'select', 'Requires Nursing?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nursing', NULL, 'prereview_nursing', NULL, 75, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nursing_doc', NULL, 'prereview_nursing', NULL, 76, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_nursing] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nursing_date_sent', NULL, 'prereview_nursing', NULL, 77, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_nursing] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nursing_date_received', NULL, 'prereview_nursing', NULL, 78, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nursing_complete', NULL, 'prereview_nursing', NULL, 79, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_cores', NULL, 'prereview_cores', 'Pre-Review Cores', 80, NULL, NULL, 'select', 'Requires Cores?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_cores', NULL, 'prereview_cores', NULL, 81, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_cores_doc', NULL, 'prereview_cores', NULL, 82, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_cores] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_cores_date_sent', NULL, 'prereview_cores', NULL, 83, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_cores] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_cores_date_received', NULL, 'prereview_cores', NULL, 84, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_cores_complete', NULL, 'prereview_cores', NULL, 85, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_sleep', NULL, 'prereview_sleep', 'Pre-Review Sleep', 86, NULL, NULL, 'select', 'Requires Sleep?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_sleep', NULL, 'prereview_sleep', NULL, 87, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_sleep_doc', NULL, 'prereview_sleep', NULL, 88, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_sleep] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_sleep_date_sent', NULL, 'prereview_sleep', NULL, 89, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_sleep] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_sleep_date_received', NULL, 'prereview_sleep', NULL, 90, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_sleep_complete', NULL, 'prereview_sleep', NULL, 91, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_nutrition', NULL, 'prereview_nutrition', 'Pre-Review Nutrition', 92, NULL, NULL, 'select', 'Requires Nutrition?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nutrition', NULL, 'prereview_nutrition', NULL, 93, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nutrition_doc', NULL, 'prereview_nutrition', NULL, 94, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_nutrition] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nutrition_date_sent', NULL, 'prereview_nutrition', NULL, 95, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_nutrition] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nutrition_date_received', NULL, 'prereview_nutrition', NULL, 96, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_nutrition_complete', NULL, 'prereview_nutrition', NULL, 97, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_community', NULL, 'prereview_community', 'Pre-Review Community', 98, NULL, NULL, 'select', 'Requires Community?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_community', NULL, 'prereview_community', NULL, 99, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_community_doc', NULL, 'prereview_community', NULL, 100, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_community] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_community_date_sent', NULL, 'prereview_community', NULL, 101, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', '[needs_community] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_community_date_received', NULL, 'prereview_community', NULL, 102, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_community_complete', NULL, 'prereview_community', NULL, 103, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_other', NULL, 'prereview_ctc', 'Pre-Review CTC', 104, NULL, NULL, 'select', 'Requires Other?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_other', NULL, 'prereview_ctc', NULL, 105, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI Suggestions', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_other_doc', NULL, 'prereview_ctc', NULL, 106, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_other_date_sent', NULL, 'prereview_ctc', NULL, 107, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_other_date_received', NULL, 'prereview_ctc', NULL, 108, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_ctc_complete', NULL, 'prereview_ctc', NULL, 109, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'needs_pi_response', NULL, 'prereview_pi_response', 'Pre-Review PI Response', 110, NULL, NULL, 'select', 'Requires PI Response?', '0, Yes \\n 1, No', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_pi_response', NULL, 'prereview_pi_response', NULL, 111, NULL, 'Enter Pre-Review Notes Or Attach File', 'textarea', 'PI response', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_pi_response_doc', NULL, 'prereview_pi_response', NULL, 112, NULL, NULL, 'file', 'OR File<br><font size=1>(NOTE: If file will not open, then Save it to your computer and then Open it.)</font>', NULL, NULL, NULL, NULL, NULL, NULL, '[needs_pi_response] = "0"', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_pi_response_date_sent', NULL, 'prereview_pi_response', NULL, 113, NULL, NULL, 'text', 'Date Sent for pre-review', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_pi_response_date_received', NULL, 'prereview_pi_response', NULL, 114, NULL, NULL, 'text', 'Date received', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prereview_pi_response_complete', NULL, 'prereview_pi_response', NULL, 115, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_percent_funded', NULL, 'post_award_administration', 'Post-Award Administration', 116, NULL, 'Post-Award Administration', 'text', 'Percent of request funded (%)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_total_award_amount', NULL, 'post_award_administration', NULL, 117, NULL, NULL, 'text', 'SRC Total Award Amount ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_letter_date', NULL, 'post_award_administration', NULL, 118, NULL, NULL, 'text', 'SRC letter sent', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_letter_document', NULL, 'post_award_administration', NULL, 119, NULL, NULL, 'file', 'SRC letter', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_project_ending', NULL, 'post_award_administration', NULL, 120, NULL, NULL, 'text', 'SRC project ending date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_full_project_period', NULL, 'post_award_administration', NULL, 121, NULL, NULL, 'text', 'SRC full project period', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_center_number', NULL, 'post_award_administration', NULL, 122, NULL, NULL, 'text', 'SRC Center Number - Institutional', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_center_number_ctsa', NULL, 'post_award_administration', NULL, 123, NULL, NULL, 'text', 'SRC Center Number - CTSA', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_center_number_crc', NULL, 'post_award_administration', NULL, 124, NULL, NULL, 'text', 'SRC Center Number - CRC', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_center_number_dh', NULL, 'post_award_administration', NULL, 125, NULL, NULL, 'text', 'D & H Number', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'comments_src', NULL, 'post_award_administration', NULL, 126, NULL, NULL, 'textarea', 'Comments - SRC Award', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_facilities', NULL, 'post_award_administration', NULL, 127, NULL, NULL, 'text', 'CRC Facilities ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_personnel', NULL, 'post_award_administration', NULL, 128, NULL, NULL, 'text', 'CRC Nursing ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'crc_cores', NULL, 'post_award_administration', NULL, 129, NULL, NULL, 'text', 'CRC Cores ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'sleep_cores', NULL, 'post_award_administration', NULL, 130, NULL, NULL, 'text', 'Sleep Core ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'vumc_core_facilities', NULL, 'post_award_administration', NULL, 131, NULL, NULL, 'text', 'VUMC Core Facilities ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'personnel', NULL, 'post_award_administration', NULL, 132, NULL, NULL, 'text', 'Personnel ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'equipment', NULL, 'post_award_administration', NULL, 133, NULL, NULL, 'text', 'Equipment ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'misc_services', NULL, 'post_award_administration', NULL, 134, NULL, NULL, 'text', 'Misc. Services ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'hospital_ancillaries', NULL, 'post_award_administration', NULL, 135, NULL, NULL, 'text', 'Hospital Ancillaries ($)', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'victr_status', NULL, 'post_award_administration', NULL, 136, NULL, NULL, 'radio', 'VICTR Status', '0, Inactive \\n 1, Active', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'src_project_completion', NULL, 'post_award_administration', NULL, 137, NULL, NULL, 'text', 'SRC completion date', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'post_award_administration_complete', NULL, 'post_award_administration', NULL, 138, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains fifteen data entry forms dedicated to recording the attributes of and tracking and progress of projects/studies.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Randomized Clinical Trial';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, randomization, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 1, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`, `data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`, `calendar`, `data_entry`, `data_quality_execute`, random_setup, random_dashboard, random_perform) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1, 1, 1, 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert randomization row
INSERT INTO redcap_randomization (project_id, stratified, group_by, target_field, target_event, source_field1, source_event1, source_field2, source_event2, source_field3, source_event3, source_field4, source_event4, source_field5, source_event5, source_field6, source_event6, source_field7, source_event7, source_field8, source_event8, source_field9, source_event9, source_field10, source_event10, source_field11, source_event11, source_field12, source_event12, source_field13, source_event13, source_field14, source_event14, source_field15, source_event15) VALUES
(@project_id, 1, NULL, 'randomization_group', NULL, 'race', @event_id, 'sex', @event_id, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num) VALUES
(@project_id, 'study_id', NULL, 'demographics', 'Demographics', 1, NULL, NULL, 'text', 'Study ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_enrolled', NULL, 'demographics', NULL, 2, NULL, 'Consent Information', 'text', 'Date subject signed consent', NULL, 'YYYY-MM-DD', 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'demographics', NULL, 3, NULL, 'Contact Information', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'demographics', NULL, 4, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'dob', '1', 'demographics', NULL, 8.1, NULL, NULL, 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'demographics', NULL, 9, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL),
(@project_id, 'race', NULL, 'demographics', NULL, 10, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'demographics', NULL, 11, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'demographics_complete', NULL, 'demographics', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),

(@project_id, 'randomization_group', NULL, 'randomization_form', 'Randomization Form', 23.1, NULL, 'General Comments', 'select', 'Randomization Group', '0, Drug A \\n 1, Drug B \\n 2, Drug C', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'randomization_form_complete', NULL, 'randomization_form', NULL, 23.2, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),


(@project_id, 'date_visit_b', NULL, 'baseline_data', 'Baseline Data', 24, NULL, 'Baseline Measurements', 'text', 'Date of baseline visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_blood_b', NULL, 'baseline_data', NULL, 25, NULL, NULL, 'text', 'Date blood was drawn', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_b', NULL, 'baseline_data', NULL, 26, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'int', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_b', NULL, 'baseline_data', NULL, 27, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_b', NULL, 'baseline_data', NULL, 28, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_b', NULL, 'baseline_data', NULL, 29, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_b', NULL, 'baseline_data', NULL, 30, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_b', NULL, 'baseline_data', NULL, 31, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_b', NULL, 'baseline_data', NULL, 32, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_b', NULL, 'baseline_data', NULL, 33, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma1_b', NULL, 'baseline_data', NULL, 34, NULL, NULL, 'select', 'Collected Plasma 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma2_b', NULL, 'baseline_data', NULL, 35, NULL, NULL, 'select', 'Collected Plasma 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma3_b', NULL, 'baseline_data', NULL, 36, NULL, NULL, 'select', 'Collected Plasma 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum1_b', NULL, 'baseline_data', NULL, 37, NULL, NULL, 'select', 'Collected Serum 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum2_b', NULL, 'baseline_data', NULL, 38, NULL, NULL, 'select', 'Collected Serum 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum3_b', NULL, 'baseline_data', NULL, 39, NULL, NULL, 'select', 'Collected Serum 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sga_b', NULL, 'baseline_data', NULL, 40, NULL, NULL, 'text', 'Subject Global Assessment (score = 1-7)', NULL, NULL, 'float', '0.9', '7.1', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_supplement_dispensed', NULL, 'baseline_data', NULL, 41, NULL, NULL, 'text', 'Date patient begins supplement', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'baseline_data_complete', NULL, 'baseline_data', NULL, 42, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_1', NULL, 'month_1_data', 'Month 1 Data', 43, NULL, 'Month 1', 'text', 'Date of Month 1 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_1', NULL, 'month_1_data', NULL, 44, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_1', NULL, 'month_1_data', NULL, 45, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_1', NULL, 'month_1_data', NULL, 46, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_1', NULL, 'month_1_data', NULL, 47, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_1', NULL, 'month_1_data', NULL, 48, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_1', NULL, 'month_1_data', NULL, 49, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_1', NULL, 'month_1_data', NULL, 50, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_1', NULL, 'month_1_data', NULL, 51, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_1', NULL, 'month_1_data', NULL, 52, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_1', NULL, 'month_1_data', NULL, 53, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_1', NULL, 'month_1_data', NULL, 54, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_1', NULL, 'month_1_data', NULL, 55, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_1', NULL, 'month_1_data', NULL, 56, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_1', NULL, 'month_1_data', NULL, 57, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_1', NULL, 'month_1_data', NULL, 58, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_1', NULL, 'month_1_data', NULL, 59, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_1', NULL, 'month_1_data', NULL, 60, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_1', NULL, 'month_1_data', NULL, 61, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_1_data_complete', NULL, 'month_1_data', NULL, 62, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_2', NULL, 'month_2_data', 'Month 2 Data', 63, NULL, 'Month 2', 'text', 'Date of Month 2 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_2', NULL, 'month_2_data', NULL, 64, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_2', NULL, 'month_2_data', NULL, 65, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_2', NULL, 'month_2_data', NULL, 66, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_2', NULL, 'month_2_data', NULL, 67, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_2', NULL, 'month_2_data', NULL, 68, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_2', NULL, 'month_2_data', NULL, 69, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_2', NULL, 'month_2_data', NULL, 70, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_2', NULL, 'month_2_data', NULL, 71, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_2', NULL, 'month_2_data', NULL, 72, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_2', NULL, 'month_2_data', NULL, 73, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_2', NULL, 'month_2_data', NULL, 74, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_2', NULL, 'month_2_data', NULL, 75, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_2', NULL, 'month_2_data', NULL, 76, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_2', NULL, 'month_2_data', NULL, 77, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_2', NULL, 'month_2_data', NULL, 78, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_2', NULL, 'month_2_data', NULL, 79, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_2', NULL, 'month_2_data', NULL, 80, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_2', NULL, 'month_2_data', NULL, 81, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_2_data_complete', NULL, 'month_2_data', NULL, 82, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_visit_3', NULL, 'month_3_data', 'Month 3 Data', 83, NULL, 'Month 3', 'text', 'Date of Month 3 visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_blood_3', NULL, 'month_3_data', NULL, 84, NULL, NULL, 'text', 'Date blood was drawn', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'alb_3', NULL, 'month_3_data', NULL, 85, 'g/dL', NULL, 'text', 'Serum Albumin (g/dL)', NULL, NULL, 'float', '3', '5', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'prealb_3', NULL, 'month_3_data', NULL, 86, 'mg/dL', NULL, 'text', 'Serum Prealbumin (mg/dL)', NULL, NULL, 'float', '10', '40', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'creat_3', NULL, 'month_3_data', NULL, 87, 'mg/dL', NULL, 'text', 'Creatinine (mg/dL)', NULL, NULL, 'float', '0.5', '20', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'npcr_3', NULL, 'month_3_data', NULL, 88, 'g/kg/d', NULL, 'text', 'Normalized Protein Catabolic Rate (g/kg/d)', NULL, NULL, 'float', '0.5', '2', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'chol_3', NULL, 'month_3_data', NULL, 89, 'mg/dL', NULL, 'text', 'Cholesterol (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'transferrin_3', NULL, 'month_3_data', NULL, 90, 'mg/dL', NULL, 'text', 'Transferrin (mg/dL)', NULL, NULL, 'float', '100', '300', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'kt_v_3', NULL, 'month_3_data', NULL, 91, NULL, NULL, 'text', 'Kt/V', NULL, NULL, 'float', '0.9', '3', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'drywt_3', NULL, 'month_3_data', NULL, 92, 'kilograms', NULL, 'text', 'Dry weight (kilograms)', NULL, NULL, 'float', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma1_3', NULL, 'month_3_data', NULL, 93, NULL, NULL, 'select', 'Collected Plasma 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma2_3', NULL, 'month_3_data', NULL, 94, NULL, NULL, 'select', 'Collected Plasma 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'plasma3_3', NULL, 'month_3_data', NULL, 95, NULL, NULL, 'select', 'Collected Plasma 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum1_3', NULL, 'month_3_data', NULL, 96, NULL, NULL, 'select', 'Collected Serum 1?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum2_3', NULL, 'month_3_data', NULL, 97, NULL, NULL, 'select', 'Collected Serum 2?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'serum3_3', NULL, 'month_3_data', NULL, 98, NULL, NULL, 'select', 'Collected Serum 3?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'sga_3', NULL, 'month_3_data', NULL, 99, NULL, NULL, 'text', 'Subject Global Assessment (score = 1-7)', NULL, NULL, 'float', '0.9', '7.1', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'no_show_3', NULL, 'month_3_data', NULL, 100, NULL, NULL, 'text', 'Number of treatments missed', NULL, NULL, 'float', '0', '7', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'compliance_3', NULL, 'month_3_data', NULL, 101, NULL, NULL, 'select', 'How compliant was the patient in drinking the supplement?', '0, 100 percent \\n 1, 99-75 percent \\n 2, 74-50 percent \\n 3, 49-25 percent \\n 4, 0-24 percent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'hospit_3', NULL, 'month_3_data', NULL, 102, NULL, 'Hospitalization Data', 'select', 'Was patient hospitalized since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_hosp_3', NULL, 'month_3_data', NULL, 103, NULL, NULL, 'select', 'What was the cause of hospitalization?', '1, Vascular access related events \\n 2, CVD events \\n 3, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'admission_date_3', NULL, 'month_3_data', NULL, 104, NULL, NULL, 'text', 'Date of hospital admission', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_date_3', NULL, 'month_3_data', NULL, 105, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'discharge_summary_3', NULL, 'month_3_data', NULL, 106, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'death_3', NULL, 'month_3_data', NULL, 107, NULL, 'Mortality Data', 'select', 'Has patient died since last visit?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'date_death_3', NULL, 'month_3_data', NULL, 108, NULL, NULL, 'text', 'Date of death', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'cause_death_3', NULL, 'month_3_data', NULL, 109, NULL, NULL, 'select', 'What was the cause of death?', '1, All-cause \\n 2, Cardiovascular', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'month_3_data_complete', NULL, 'month_3_data', NULL, 110, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', 'Completion Data', 111, NULL, 'Study Completion Information', 'select', 'Has patient completed study?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 112, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 113, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'complete_study_date', NULL, 'completion_data', NULL, 114, NULL, NULL, 'text', 'Date of study completion', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', NULL, 115, NULL, 'General Comments', 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 116, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains seven data entry forms for collecting data for a randomized clinical trial. Includes a short demographics form followed by a form where randomization is performed. An example randomization model has already been set up, although randomization allocation tables have not yet been created.',  '1');

-- Since project is in development, go ahead and pre-check items on Project Setup
INSERT INTO redcap_project_checklist (project_id, `name`) VALUES
(@project_id, 'design'),
(@project_id, 'modify_project'),
(@project_id, 'modules');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Human Cancer Tissue Biobank';


-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, display_project_logo_institution, randomization, auto_inc_set) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 0, 0, 1);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`, `data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`, `calendar`, `data_entry`, `data_quality_execute`, random_setup, random_dashboard, random_perform) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 1, 0, 0, 0);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'lab_id', '0', 'id_shipping', 'ID Shipping', 1, NULL, 'IDs', 'text', 'Lab ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'trc_id', NULL, 'id_shipping', NULL, 2, NULL, NULL, 'text', 'TRC ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'id_shipping', NULL, 3, NULL, NULL, 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'middle_name', NULL, 'id_shipping', NULL, 4, NULL, NULL, 'text', 'Middle Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'id_shipping', NULL, 5, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'suffix', NULL, 'id_shipping', NULL, 6, NULL, NULL, 'text', 'Suffix', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_of_birth', '1', 'id_shipping', NULL, 7, NULL, NULL, 'text', 'Date of Birth', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'age', NULL, 'id_shipping', NULL, 8, NULL, NULL, 'text', 'Age', NULL, 'Age at surgery, DOB not available', 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_name', NULL, 'id_shipping', NULL, 9, NULL, 'Shipping Information', 'text', 'Facility_Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_city', NULL, 'id_shipping', NULL, 10, NULL, NULL, 'text', 'Facility_City', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_state', NULL, 'id_shipping', NULL, 11, NULL, NULL, 'text', 'Facility_State', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'receivedate', '1', 'id_shipping', NULL, 12, NULL, NULL, 'text', 'ReceiveDate', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'shipmethod', NULL, 'id_shipping', NULL, 13, NULL, NULL, 'select', 'ShipMethod', '1, FedEx \\n 2, USPS \\n 3, UPS \\n 4, ByPerson \\n 5, Others', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'trackingnumber', NULL, 'id_shipping', NULL, 14, NULL, NULL, 'text', 'ReceiveTracking', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathaccnumber', '1', 'id_shipping', NULL, 15, NULL, NULL, 'text', 'PathAccNumber', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'otheraccnumber2', NULL, 'id_shipping', NULL, 16, NULL, NULL, 'text', 'OtherAccNumber', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'blk_no_received', NULL, 'id_shipping', NULL, 17, NULL, NULL, 'text', 'Block_ Received', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'stainedslide_received', NULL, 'id_shipping', NULL, 18, NULL, NULL, 'text', 'StainedSlide_Received', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'unstainedslide_received', NULL, 'id_shipping', NULL, 19, NULL, NULL, 'text', 'UnstainedSlide_Received', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_needed', NULL, 'id_shipping', NULL, 20, NULL, NULL, 'yesno', 'Return_Needed?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_date', NULL, 'id_shipping', NULL, 21, NULL, NULL, 'text', 'ReturnDate', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_tracking', NULL, 'id_shipping', NULL, 22, NULL, NULL, 'text', 'ReturnTracking', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'labcirculation_time', NULL, 'id_shipping', NULL, 23, NULL, NULL, 'calc', 'LabCirculation_time', 'round(datediff([receivedate],[return_date],"d","mdy"))', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'followup_note', NULL, 'id_shipping', NULL, 24, NULL, NULL, 'textarea', 'FollowUp_Note', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'secondtime_getsample', NULL, 'id_shipping', NULL, 25, NULL, 'If Receive Sample 2nd Time', 'yesno', '2nd_Time_Receive', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'follow_up_needed2', NULL, 'id_shipping', NULL, 26, NULL, NULL, 'yesno', 'Follow up needed?', NULL, NULL, NULL, NULL, NULL, NULL, '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'collection_note2', NULL, 'id_shipping', NULL, 27, NULL, NULL, 'textarea', 'FollowUp_Note2', NULL, NULL, NULL, NULL, NULL, NULL, '[follow_up_needed2] = ''1'' and [secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'samefacasbefore', NULL, 'id_shipping', NULL, 28, NULL, NULL, 'yesno', 'SameFacilityAsBefore?', NULL, NULL, NULL, NULL, NULL, NULL, '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_name2', NULL, 'id_shipping', NULL, 29, NULL, NULL, 'text', 'Facility_Name2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[samefacasbefore] = ''0'' and [secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_city2', NULL, 'id_shipping', NULL, 30, NULL, NULL, 'text', 'Facility_City2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1'' and [samefacasbefore] = ''0''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_state2', NULL, 'id_shipping', NULL, 31, NULL, NULL, 'text', 'Facility_State2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1'' and [samefacasbefore] = ''0''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'receivedate2', NULL, 'id_shipping', NULL, 32, NULL, NULL, 'text', 'ReceiveDate2', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'shipmethod2', NULL, 'id_shipping', NULL, 33, NULL, NULL, 'select', 'ShipMethod2', '1, FedEx \\n 2, USPS \\n 3, UPS \\n 4, ByPerson \\n 5, Others', NULL, NULL, NULL, NULL, NULL, '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'receivetracking2', NULL, 'id_shipping', NULL, 34, NULL, NULL, 'text', 'ReceiveTracking2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathaccnumber2', NULL, 'id_shipping', NULL, 35, NULL, NULL, 'text', 'PathAccNumber', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'otheraccnumber', NULL, 'id_shipping', NULL, 36, NULL, NULL, 'text', 'OtherAccNumber', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_received2', NULL, 'id_shipping', NULL, 37, NULL, NULL, 'text', 'Block_ Received2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'stainedslide_received2', NULL, 'id_shipping', NULL, 38, NULL, NULL, 'text', 'StainedSlide_Received2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'unstainedslide_received2', NULL, 'id_shipping', NULL, 39, NULL, NULL, 'text', 'UnstainedSlide_Received2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_needed2', NULL, 'id_shipping', NULL, 40, NULL, NULL, 'yesno', 'Return_needed?', NULL, NULL, NULL, NULL, NULL, NULL, '[secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'returndate2', NULL, 'id_shipping', NULL, 41, NULL, NULL, 'text', 'ReturnDate2', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', '[return_needed2] = ''1'' and [secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_tracking2', NULL, 'id_shipping', NULL, 42, NULL, NULL, 'text', 'ReturnTracking2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[return_needed2] = ''1'' and [secondtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'thirdtime_getsample', NULL, 'id_shipping', NULL, 43, NULL, 'If Receive Sample 3rd Time', 'yesno', '3rd_Time_Receive', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'follow_up_needed3', NULL, 'id_shipping', NULL, 44, NULL, NULL, 'yesno', 'Follow up needed?', NULL, NULL, NULL, NULL, NULL, NULL, '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'collection_note3', NULL, 'id_shipping', NULL, 45, NULL, NULL, 'textarea', 'FollowUp_Note', NULL, NULL, NULL, NULL, NULL, NULL, '[follow_up_needed3] = ''1'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'samefacilityasbefore2', NULL, 'id_shipping', NULL, 46, NULL, NULL, 'yesno', 'SameFacilityAsBefore?', NULL, NULL, NULL, NULL, NULL, NULL, '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_name3', NULL, 'id_shipping', NULL, 47, NULL, NULL, 'text', 'Facility_Name3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[samefacilityasbefore2] = ''0'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_city3', NULL, 'id_shipping', NULL, 48, NULL, NULL, 'text', 'Facility_City3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[samefacilityasbefore2] = ''0'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'facility_state3', NULL, 'id_shipping', NULL, 49, NULL, NULL, 'text', 'Facility_State3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[samefacilityasbefore2] = ''0'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'receivedate3', NULL, 'id_shipping', NULL, 50, NULL, NULL, 'text', 'ReceiveDate3', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'shipmethod3', NULL, 'id_shipping', NULL, 51, NULL, NULL, 'select', 'ShipMethod3', '1, FedEx \\n 2, USPS \\n 3, UPS \\n 4, ByPerson \\n 5, Others', NULL, NULL, NULL, NULL, NULL, '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'receivetracking3', NULL, 'id_shipping', NULL, 52, NULL, NULL, 'text', 'ReceiveTracking3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathaccnumber3', NULL, 'id_shipping', NULL, 53, NULL, NULL, 'text', 'PathAccNumber3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'otheraccnumber3', NULL, 'id_shipping', NULL, 54, NULL, NULL, 'text', 'OtherAccNumber', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_received3', NULL, 'id_shipping', NULL, 55, NULL, NULL, 'text', 'Block_ Received3', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'stainedslide_received3', NULL, 'id_shipping', NULL, 56, NULL, NULL, 'text', 'StainedSlide_Received3', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'unstainedslide_received3', NULL, 'id_shipping', NULL, 57, NULL, NULL, 'text', 'UnstainedSlide_Received3', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'return_needed3', NULL, 'id_shipping', NULL, 58, NULL, NULL, 'yesno', 'Return_needed?', NULL, NULL, NULL, NULL, NULL, NULL, '[thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'returndate3', NULL, 'id_shipping', NULL, 59, NULL, NULL, 'text', 'ReturnDate3', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', '[return_needed3] = ''1'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'returntracking3', NULL, 'id_shipping', NULL, 60, NULL, NULL, 'text', 'ReturnTracking3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[return_needed3] = ''1'' and [thirdtime_getsample] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'id_shipping_complete', NULL, 'id_shipping', NULL, 61, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tumor_origin', NULL, 'pathology_review', 'Pathology Review', 62, NULL, 'Tumor Origin and Location', 'select', 'Tumor_Origin', '1, Breast \\n 2, Prostate \\n 3, Colorectum \\n 4, Lung \\n 5, Others', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_other_origin', NULL, 'pathology_review', NULL, 63, NULL, NULL, 'text', 'Specify_Other_Origin', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tumor_location', NULL, 'pathology_review', NULL, 64, NULL, NULL, 'select', 'Location_Breast_Prostate', '1, Left \\n 2, Right \\n 3, Bilateral \\n 4, Multiple \\n 5, Unclear', 'Multiple means 2 or more', NULL, NULL, NULL, NULL, '[tumor_origin] = ''1'' or [tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tumor_location_colorectum', NULL, 'pathology_review', NULL, 65, NULL, NULL, 'select', 'Location_Colorectum', '1, Appendix \\n 2, Cecum \\n 3, Ascending \\n 4, Hepatic Flexure \\n 5, Transverse \\n 6, Splenic Flexure \\n 7, Descending \\n 8, Sigmoid \\n 9, Rectum \\n 10, Anus \\n 11, Left \\n 12, Right \\n 13, Unclear', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tumor_location_lung', NULL, 'pathology_review', NULL, 66, NULL, NULL, 'select', 'Location_Lung', '1, Right Upper Lobe \\n 2, Right Middle Lobe \\n 3, Right Lower Lobe \\n 4, Left Upper Lobe \\n 5, Left Lower Lobe \\n 6, Right Bronchus \\n 7, Left Bronchus \\n 8, Right \\n 9, Left \\n 10, Unclear \\n 11, Others (specify it)', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'other_location_lung', NULL, 'pathology_review', NULL, 67, NULL, NULL, 'text', 'Other location_lung', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''4'' and [tumor_location_lung] = ''11''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_other_location', NULL, 'pathology_review', NULL, 68, NULL, NULL, 'text', 'Specify_Other_Location', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_surgery', NULL, 'pathology_review', NULL, 69, NULL, 'Clinical Pathology Information', 'text', 'Date_Surgery', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'age_at_surgery', NULL, 'pathology_review', NULL, 70, NULL, NULL, 'calc', 'Age at Surgery', 'round(datediff([date_of_birth],[date_surgery],"y","mdy",true),0)', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'pathology_review', NULL, 71, NULL, NULL, 'select', 'Sex', '1, male \\n 2, female \\n 3, N/A', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathol_acc_no', '1', 'pathology_review', NULL, 72, NULL, NULL, 'text', 'Pathol_Acc_No', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'other_acc_no', NULL, 'pathology_review', NULL, 73, NULL, NULL, 'text', 'Other_Acc_No', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_tumor', NULL, 'pathology_review', NULL, 74, NULL, NULL, 'text', 'BlockNum_Tumor', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_normal', NULL, 'pathology_review', NULL, 75, NULL, NULL, 'text', 'BlockNum_Normal', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_metastatic', NULL, 'pathology_review', NULL, 76, NULL, NULL, 'text', 'BlockNum_Metastatic', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'block_precancerous', NULL, 'pathology_review', NULL, 77, NULL, NULL, 'text', 'BlockNum_Precancerous', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'invitrosize1', NULL, 'pathology_review', NULL, 78, NULL, NULL, 'text', 'InvitroSize1', NULL, 'Maximum size in centimeter', 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'invitrosize2', NULL, 'pathology_review', NULL, 79, NULL, NULL, 'text', 'InvitroSize2', NULL, 'In % of total tissue volume for prostate cancer', 'float', NULL, NULL, 'soft_typed', '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'invitrosize3', NULL, 'pathology_review', NULL, 80, NULL, NULL, 'text', 'InvitroSize3', NULL, 'The seceond largest tumor', NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'perineuralinvasion', NULL, 'pathology_review', NULL, 81, NULL, NULL, 'select', 'PerineuralInvasion', '0, No \\n 1, Yes \\n 2, N/A', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'vascular_invasion', NULL, 'pathology_review', NULL, 82, NULL, NULL, 'select', 'Vascular invasion present', '0, No \\n 1, Yes \\n 2, N/A', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'surgical_margin_cancer_pre', NULL, 'pathology_review', NULL, 83, NULL, NULL, 'select', 'Surgical margin cancer present', '0, No \\n 1, Yes \\n 2, N/A', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_diagn_breast', NULL, 'pathology_review', NULL, 84, NULL, 'For Breast Cancer Samples', 'select', 'Clin_Diagn_Breast', '1, Noninvasive carcinoma (NOS) \\n 2, Ductal carcinoma in situ \\n 3, Lobular carcinoma in situ \\n 4, Paget disease without invasive carcinoma \\n 5, Invasive carcinoma (NOS) \\n 6, Invasive ductal carcinoma \\n 7, IDC with an extensive intraductal component \\n 8, IDC with Paget disease \\n 9, Invasive lobular \\n 10, Mucinous \\n 11, Medullary \\n 12, Papillary \\n 13, Tubular \\n 14, Adenoid cystic \\n 15, Secretory (juvenile) \\n 16, Apocrine \\n 17, Cribriform \\n 18, Carcinoma with squamous metaplasia \\n 19, Carcinoma with spindle cell metaplasia \\n 20, Carcinoma with cartilaginous/osseous metaplasia \\n 21, Carcinoma with metaplasia, mixed type \\n 22, Other(s) (specify) \\n 23, Not assessable \\n 24, No cancer tissue \\n 25, IDC+ILC (50 -90% each component)', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_diagn_breast', NULL, 'pathology_review', NULL, 85, NULL, NULL, 'select', 'Lab_Diagn_Breast', '1, Noninvasive carcinoma (NOS) \\n 2, Ductal carcinoma in situ \\n 3, Lobular carcinoma in situ \\n 4, Paget disease without invasive carcinoma \\n 5, Invasive carcinoma (NOS) \\n 6, Invasive ductal carcinoma \\n 7, IDC with an extensive intraductal component \\n 8, IDC with Paget disease \\n 9, Invasive lobular \\n 10, Mucinous \\n 11, Medullary \\n 12, Papillary \\n 13, Tubular \\n 14, Adenoid cystic \\n 15, Secretory (juvenile) \\n 16, Apocrine \\n 17, Cribriform \\n 18, Carcinoma with squamous metaplasia \\n 19, Carcinoma with spindle cell metaplasia \\n 20, Carcinoma with cartilaginous/osseous metaplasia \\n 21, Carcinoma with metaplasia, mixed type \\n 22, Other(s) (specify) \\n 23, Not assessable \\n 24, No cancer tissue \\n 25, IDC+ILC (50 -90% each component)', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'if_ilc_subtype', NULL, 'pathology_review', NULL, 86, NULL, NULL, 'select', 'ILC_Subtype', '901, classical ILC \\n 902, solid ILC \\n 903, pleomorphic ILC \\n 904, alveolar ILC \\n 905, tubulolobular ILC \\n 906, mixed ILC \\n 907, signet ring cell ILC \\n 908, others', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1'' and [lab_diagn_breast] = ''9''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_if_other_type_br', NULL, 'pathology_review', NULL, 87, NULL, NULL, 'text', 'Specify_If_Other_Type_Br', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_grade_breast', NULL, 'pathology_review', NULL, 88, NULL, NULL, 'select', 'Clin_Grade_Breast', '1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 1~2 \\n 5, 2~3 \\n 6, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_grade_breast', NULL, 'pathology_review', NULL, 89, NULL, NULL, 'select', 'Lab_Grade_Breast', '1, 1 \\n 2, 2 \\n 3, 3 \\n 4, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'estrogen_receptor', NULL, 'pathology_review', NULL, 90, NULL, NULL, 'select', 'Estrogen Receptor', '0, negative \\n 1, week (<1%) \\n 2, positive (>=1%) \\n 3, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'progesterone_receptor', NULL, 'pathology_review', NULL, 91, NULL, NULL, 'select', 'Progesterone Receptor', '0, negative (0~2) \\n 1, week (3~4) \\n 2, intermediate (5~6) \\n 3, strong (7~8) \\n 4, N/A', 'Allred Score System 0-8', NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'her2_immunohistochemistry', NULL, 'pathology_review', NULL, 92, NULL, NULL, 'select', 'HER2_Immunohistochemistry', '0, 0 \\n 1, 1 (1~9% cells positivity) \\n 2, 2 (10-30% cells positivity) \\n 3, 3 (>30% cells positivity with strong color) \\n 4, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'her2_fish', NULL, 'pathology_review', NULL, 93, NULL, NULL, 'select', 'HER2_FISH', '0, 0 (Non-Amplified, <1.8) \\n 1, 1 (Amplified, >2.2) \\n 2, 2 (Borderline, 1.8~2.2) \\n 3, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'bc_molecularsubtype', NULL, 'pathology_review', NULL, 94, NULL, NULL, 'select', 'BC_MolecularSubtype', '1, Luminal A \\n 2, Luminal B \\n 3, HER2 \\n 4, Triple Negative \\n 5, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ki_67', NULL, 'pathology_review', NULL, 95, NULL, NULL, 'text', 'Ki-67', NULL, 'positive cells in percentage', 'float', NULL, NULL, 'soft_typed', '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'p53_ihc', NULL, 'pathology_review', NULL, 96, NULL, NULL, 'text', 'p53_IHC', NULL, 'positive cells in percentage', NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'dna_index', NULL, 'pathology_review', NULL, 97, NULL, NULL, 'text', 'DNA Index', NULL, 'Unfavorable: >1.1', NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'bc_precancerous', NULL, 'pathology_review', NULL, 98, NULL, NULL, 'select', 'BC_Precancerous', '1, Not seen \\n 2, DCIS \\n 3, LCIS \\n 4, DCIS+LCIS', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnm_breast_tumor', NULL, 'pathology_review', NULL, 99, NULL, NULL, 'select', 'TNMbreast_PrimTum(T)', '1, TX:Primary tumor cannot be assessed \\n 2, T0:No evidence of primary tumor \\n 3, Tis:DCIS/LCIS/Paget''s dis w/o associated tumor \\n 4, T1mic:Microinvasion <=0.1 cm \\n 5, T1a:>0.1 but <=0.5 cm \\n 6, T1b:>0.5 cm but <=1.0 cm \\n 7, T1c:>1.0 cm but <=2.0 cm \\n 8, T2:Tumor >2.0 cm but <=5.0 cm \\n 9, T3:Tumor >5.0 cm \\n 10, T4a:Any size with direct extension to chest wall \\n 11, T4b:skin Edema/ulceration;satellite skin nodules \\n 12, T4c:Both of T4a and T4b \\n 13, T4d:Inflammatory carcinoma', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmbreast_ln_n', NULL, 'pathology_review', NULL, 100, NULL, NULL, 'select', 'TNMbreast_LN (N)', '1, NX: Regional LNs cannot be assessed \\n 2, N0: No regional LNs metastasis \\n 3, N1: Movable ipsilateral axillary LN(s) \\n 4, N2: Ipsilateral axillary LN(s) fixed \\n 5, N3: Ipsilateral internal mammary LN(s) \\n 6, pNX: Regional LNs cannot be assessed \\n 7, pN0: No regional LNs metastasis \\n 8, pN1: movable ipsilateral axillary LN(s) \\n 9, pN1a:Only micrometastasis <=0.2 cm \\n 10, pN1b: Metastasis any >0.2 cm \\n 11, pN1bi:1 to 3 LNs, any >0.2 cm and all <2.0 cm \\n 12, pN1bii: >=4 LN3, any >0.2 cm and all <2.0 cm \\n 13, pN1biii: beyond LN capsule,metastasis <2.0 cm \\n 14, pN1biv: Metastasis to a LN >=2.0 cm \\n 15, pN2: to ipsilateral axillaryLN(s) fixed \\n 16, pN3: to ipsilateral internal mammary LN(s) \\n 17, pN0(i+)', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmbreast_distantmetast_m', NULL, 'pathology_review', NULL, 101, NULL, NULL, 'select', 'TNMbreast_DistantMetast (M)', '1, MX: cannot be assessed \\n 2, M0: No distant metastasis \\n 3, M1: yes includes ipsilateral supraclavicular LNs', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_diagn_prostate', NULL, 'pathology_review', NULL, 102, NULL, 'For Prostate Cancer Samples', 'select', 'Clin_Diagn_Prostate', '1, Adenocarcinoma,NOS \\n 2, Prostatic duct adenocarcinoma \\n 3, Mucinous adenocarcinoma \\n 4, Signet-ring cell carcinoma \\n 5, Adenosquemous carcinoma \\n 6, Small cell carcinoma \\n 7, Sarcomatoid carcinoma \\n 8, Other (specifiy) \\n 9, Undifferentiated carcinoma, NOS \\n 10, Cannot be determined', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_diag_prostate', NULL, 'pathology_review', NULL, 103, NULL, NULL, 'select', 'Lab_Diag_Prostate', '1, Adenocarcinoma,NOS \\n 2, Prostatic duct adenocarcinoma \\n 3, Mucinous adenocarcinoma \\n 4, Signet-ring cell carcinoma \\n 5, Adenosquemous carcinoma \\n 6, Small cell carcinoma \\n 7, Sarcomatoid carcinoma \\n 8, Other (specifiy) \\n 9, Undifferentiated carcinoma, NOS \\n 10, Cannot be determined', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_if_other_type_pro', NULL, 'pathology_review', NULL, 104, NULL, NULL, 'text', 'Specify_If_Other_type_Pro', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_gleason_score', NULL, 'pathology_review', NULL, 105, NULL, NULL, 'text', 'Clin_Gleason_Score', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_grade_pro', NULL, 'pathology_review', NULL, 106, NULL, NULL, 'select', 'Clin_Grade_Pro', '1, Low(1-4) \\n 2, Intermediate(5-7) \\n 3, High(8-10)', 'Gleason Score System', NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_gleason_score', NULL, 'pathology_review', NULL, 107, NULL, NULL, 'text', 'Lab_Gleason_Score', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_grade_pro', NULL, 'pathology_review', NULL, 108, NULL, NULL, 'select', 'Lab_Grade_Pro', '1, Low(1-4) \\n 2, Intermediate(5-7) \\n 3, High(8-10)', 'Gleason Score System (1-10)', NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmprostate_t', NULL, 'pathology_review', NULL, 109, NULL, NULL, 'select', 'TNMprostate_T', '1, T1: Microscopic, DRE/Ultrasound undetectable \\n 2, T1a: <=5 percent \\n 3, T1b: >5 percent \\n 4, T1c: as F/U of screening w/ high PSA \\n 5, T2: within prost, DRE/ultrasound detectable \\n 6, T2a: >half of one lobe \\n 7, T2b: >half of one lobe,DRE detectable often \\n 8, T2c: involve both lobes \\n 9, T3: surrounding tissues or seminal vesicles \\n 10, T3a: outside prostate on one side \\n 11, T3b: outside prostate on both sides \\n 12, T3c: to one or both seminal tubes \\n 13, T4a: to bladder or rectum \\n 14, T4b: beyond prostate or levator muscles \\n 15, TX', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmprostate_n', NULL, 'pathology_review', NULL, 110, NULL, NULL, 'select', 'TNMprostate_N', '1, N0: not to pelvic LN \\n 2, N1: a single pelvic LN,<= 2 cm \\n 3, N2: a single pelvic LN,2-5cm \\n 4, N3: >5 cm in size \\n 5, NX', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmprostate_m', NULL, 'pathology_review', NULL, 111, NULL, NULL, 'select', 'TNMprostate_M', '1, M0: spread only regionally in pelvic area \\n 2, M1: spread beyond pelvic area \\n 3, MX', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'psa_level', NULL, 'pathology_review', NULL, 112, NULL, NULL, 'text', 'PSA_Level', NULL, 'ng/mL', NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'seminalinvasion', NULL, 'pathology_review', NULL, 113, NULL, NULL, 'select', 'SeminalInvasion', '0, No \\n 1, Yes \\n 2, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'extraprostate_extention', NULL, 'pathology_review', NULL, 114, NULL, NULL, 'select', 'ExtraProstate Extention', '0, No \\n 1, Yes \\n 2, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''2''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_giag_colon', NULL, 'pathology_review', NULL, 115, NULL, 'For Colon Cancer Samples', 'select', 'Clin_Diagn_Colon', '1, 1 Adenocarcinoma \\n 2, 2 Mucinous adenocarcinoma \\n 3, 3 Medullary carcinoma \\n 4, 4 Signet ring cell carcinoma \\n 5, 5 Small cell carcinoma \\n 6, 6 Squamous cell carcinoma \\n 7, 7 Adenosquamous carcinoma \\n 8, 8 Others \\n 9, 9 Adenoma', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_colon_clin', NULL, 'pathology_review', NULL, 116, NULL, NULL, 'text', 'If others_specify', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''3'' and [clin_giag_colon] = ''8''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_diagn_colon', NULL, 'pathology_review', NULL, 117, NULL, NULL, 'select', 'Lab_Diagn_Colon', '1, 1 Adenocarcinoma \\n 2, 2 Mucinous adenocarcinoma \\n 3, 3 Medullary carcinoma \\n 4, 4 Signet ring cell carcinoma \\n 5, 5 Small cell carcinoma \\n 6, 6 Squamous cell carcinoma \\n 7, 7 Adenosquamous carcinoma \\n 8, 8 Others \\n 9, 9 Adenoma', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'specify_colon_lab', NULL, 'pathology_review', NULL, 118, NULL, NULL, 'text', 'If others_specify', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''3'' and [lab_diagn_colon] = ''8''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_grade_colon', NULL, 'pathology_review', NULL, 119, NULL, NULL, 'select', 'Clin_Grade_Colon', '1, Low \\n 2, Intermediate \\n 3, High \\n 4, N/A \\n 5, Low-Intermediate \\n 6, Intermediate-High', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_grade_colon', NULL, 'pathology_review', NULL, 120, NULL, NULL, 'select', 'Lab_Grade_Colon', '1, Low \\n 2, Intermediate \\n 3, High \\n 4, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmcolon_t', NULL, 'pathology_review', NULL, 121, NULL, NULL, 'select', 'TNMcolon_T', 'Tx, Tx \\n Tis, Tis earliest stage (in situ) involves only mucosa \\n T1, T1 through the muscularis mucosa \\n T2, T2 through submucosa into muscularis propria \\n T3, T3 through muscularis propria into outermost layers \\n T4a, T4a through serosa/visceral peritoneum \\n T4b, T4b through the wall attach/invade nearby tissues', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmcolon_n', NULL, 'pathology_review', NULL, 122, NULL, NULL, 'select', 'TNMcolon_N', 'Nx, Nx incomplete information. \\n N0, N0 No cancer in nearby LNs \\n N1a, N1a in 1 nearby LN \\n N1b, N1b in 2 to 3 nearby LNs \\n N1c, N1c cancer cells in areas of fat near LN, but not in LNs \\n N2a, N2a in 4 to 6 nearby LN \\n N2b, N2b in 7 or more nearby LNs', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmcolon_m', NULL, 'pathology_review', NULL, 123, NULL, NULL, 'select', 'TNMcolon_M', 'M0, M0 No distant spread \\n M1a, M1a to 1 distant organ or set of distant LNs \\n M1b, M1b to >1 or distant parts peritoneum \\n MX, MX', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pre_cancerous_colon', NULL, 'pathology_review', NULL, 124, NULL, NULL, 'textarea', 'Pre-cancerous_Colon', NULL, NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''3''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_diagn_lung', NULL, 'pathology_review', NULL, 125, NULL, 'For Lung Cancer Samples', 'select', 'Clin_Diagn_Lung', '1, Squamous cell carcinoma 8070/3 \\n 2, Small cell carcinoma 8041/3 \\n 3, Adenocarcinoma 8140/3 \\n 4, Adenocarcinoma, mixed subtype 8255/3 \\n 5, Adenocarcinoma, Acinar 8550/3 \\n 6, Adenocarcinoma, Papillary 8260/3 \\n 7, Adenocarcinoma, Micropapillary \\n 8, Bronchioloalveolar carcinoma 8250/3 \\n 9, Solid adenocarcinoma with mucin 8230/3 \\n 10, Adenosquamous carcinoma 8560/3 \\n 11, Large cell carcinoma 8012/3 \\n 12, Sarcomatoid carcinoma 8033/3 \\n 13, Carcinoid tumour 8240/3 \\n 14, Mucoepidermoid carcinoma 8430/3 \\n 15, Epithelial-myoepithelial carcinoma 8562/3 \\n 16, Adenoid cystic carcinoma 8200/3 \\n 17, Unclassified carcinoma \\n 18, Others \\n 19, Large cell neuroendocrine carcinoma  8013/3', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_diagn_lung', NULL, 'pathology_review', NULL, 126, NULL, NULL, 'select', 'Lab_Diagn_Lung', '1, Squamous cell carcinoma 8070/3 \\n 2, Small cell carcinoma 8041/3 \\n 3, Adenocarcinoma 8140/3 \\n 4, Adenocarcinoma, mixed subtype 8255/3 \\n 5, Adenocarcinoma, Acinar 8550/3 \\n 6, Adenocarcinoma, Papillary 8260/3 \\n 7, Adenocarcinoma, Micropapillary \\n 8, Bronchioloalveolar carcinoma 8250/3 \\n 9, Solid adenocarcinoma with mucin 8230/3 \\n 10, Adenosquamous carcinoma 8560/3 \\n 11, Large cell carcinoma 8012/3 \\n 12, Sarcomatoid carcinoma 8033/3 \\n 13, Carcinoid tumour 8240/3 \\n 14, Mucoepidermoid carcinoma 8430/3 \\n 15, Epithelial-myoepithelial carcinoma 8562/3 \\n 16, Adenoid cystic carcinoma 8200/3 \\n 17, Unclassified carcinoma \\n 18, Others \\n 19, Large cell neuroendocrine carcinoma 8013/3', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'if_others_specify', NULL, 'pathology_review', NULL, 127, NULL, NULL, 'text', 'If_Others_Specify', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''4'' and [lab_diagn_lung] = ''10''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_grade_lung', NULL, 'pathology_review', NULL, 128, NULL, NULL, 'select', 'Clin_Grade_Lung', '1, Low \\n 2, Intermediate \\n 3, High \\n 4, N/A \\n 5, Low-Intermediate \\n 6, Intermediate-High', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_grade_lung', NULL, 'pathology_review', NULL, 129, NULL, NULL, 'select', 'Lab_Grade_Lung', '1, Low \\n 2, Intermediate \\n 3, High \\n 4, N/A', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmlung_t', NULL, 'pathology_review', NULL, 130, NULL, NULL, 'select', 'TNMlung_T', '1, TX \\n 2, T0 No evidence of primary tumour \\n 3, Tis Carcinoma in situ \\n 4, T1 <= 3 cm, without invasion \\n 5, T2 > 3 cm; or involves main bronchus(>2 cm distal to carina)/visceral pleura; or Associated with atelectasis or obstructive pneumonitis that does not involve entire lung \\n 6, T3 any size that directly invades any of:chest wall, diaphragm, mediastinal pleura, parietal pericardium; or tumour in main bronchus < 2 cm distal to carina but without involvement of carina; or associated atelectasis or obstructive pneumonitis of entire lung \\n 7, T4 any size that invades any of: mediastinum, heart, great vessels, trachea, oesophagus, vertebral body, carina; separate tumour nodule(s) in same lobe; tumour with malignant pleural effusion', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmlung_n', NULL, 'pathology_review', NULL, 131, NULL, NULL, 'select', 'TNMlung_N', '8, NX \\n 9, N0 \\n 10, N1 Ipsilateral peribronchial/ipsilateral hilar LNs and intrapulmonary LNs \\n 11, N2 ipsilateral mediastinal/subcarinal LNs \\n 12, N3 contralateral mediastinal, contralateral hilar, ipsilateral or contralateral scalene, or supraclavicular LNs', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnmlung_m', NULL, 'pathology_review', NULL, 132, NULL, NULL, 'select', 'TNMlung_M', '13, MX \\n 14, M0 \\n 15, M1 Distant metastasis, includes separate tumour nodule(s) in different lobe', NULL, NULL, NULL, NULL, NULL, '[tumor_origin] = ''4''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_diagn_others', NULL, 'pathology_review', NULL, 133, NULL, 'For Other Cancer Samples', 'text', 'Clin_Diagn_Others', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_diagn_others', NULL, 'pathology_review', NULL, 134, NULL, NULL, 'text', 'Lab_Diagn_Others', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'clin_grade_others', NULL, 'pathology_review', NULL, 135, NULL, NULL, 'text', 'Clin_Grade_Others', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'lab_grade_others', NULL, 'pathology_review', NULL, 136, NULL, NULL, 'text', 'Lab_Grade_Others', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tnm_stage', NULL, 'pathology_review', NULL, 137, NULL, NULL, 'text', 'TNM_Stage', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[tumor_origin] = ''5''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathoireview_note', NULL, 'pathology_review', NULL, 138, NULL, NULL, 'textarea', 'PatholReview_Note', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathology_review_complete', NULL, 'pathology_review', NULL, 139, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_tumor_quant', NULL, 'slide_information', 'Slide Information', 140, NULL, NULL, 'text', '5um_Tumor_Quant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_tumor_currquant', NULL, 'slide_information', NULL, 141, NULL, NULL, 'text', '5um_Tumor_CurrQuant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_tumor_quant', NULL, 'slide_information', NULL, 142, NULL, NULL, 'text', '10um_Tumor_Quant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_tumor_currquant', NULL, 'slide_information', NULL, 143, NULL, NULL, 'text', '10um_Tumor_CurrQuant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_nor_quant', NULL, 'slide_information', NULL, 144, NULL, NULL, 'text', '5um_Nor_Quant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_nor_currquant', NULL, 'slide_information', NULL, 145, NULL, NULL, 'text', '5um_Nor_CurrQuant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_nor_quant', NULL, 'slide_information', NULL, 146, NULL, NULL, 'text', '10um_Nor_Quant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_nor_currquant', NULL, 'slide_information', NULL, 147, NULL, NULL, 'text', '10um_Nor_CurrQuant', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slideloc_1', NULL, 'slide_information', NULL, 148, NULL, NULL, 'text', 'SlideLoc_1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'parapieceloc_1', NULL, 'slide_information', NULL, 149, NULL, NULL, 'text', 'ParaPieceLoc_1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'is_there_another_accnumber', NULL, 'slide_information', NULL, 150, NULL, NULL, 'yesno', 'Is there another AccNumber?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pathaccnum_2', NULL, 'slide_information', NULL, 151, NULL, NULL, 'text', 'PathAccNum_2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_tumor_quant2', NULL, 'slide_information', NULL, 152, NULL, NULL, 'text', '5um_Tumor_Quant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_tumor_currquant2', NULL, 'slide_information', NULL, 153, NULL, NULL, 'text', '5um_Tumor_CurrQuant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_tumor_quant2', NULL, 'slide_information', NULL, 154, NULL, NULL, 'text', '10um_Tumor_Quant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_tumor_currquant2', NULL, 'slide_information', NULL, 155, NULL, NULL, 'text', '10um_Tumor_CurrQuant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_nor_quant2', NULL, 'slide_information', NULL, 156, NULL, NULL, 'text', '5um_Nor_Quant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_nor_currquant2', NULL, 'slide_information', NULL, 157, NULL, NULL, 'text', '5um_Nor_CurrQuant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_nor_quant2', NULL, 'slide_information', NULL, 158, NULL, NULL, 'text', '10um_Nor_Quant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_nor_currquant2', NULL, 'slide_information', NULL, 159, NULL, NULL, 'text', '10um_Nor_CurrQuant2', NULL, NULL, 'float', NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'same_slideloc', NULL, 'slide_information', NULL, 160, NULL, NULL, 'yesno', 'Same_SlideLoc?', NULL, NULL, NULL, NULL, NULL, NULL, '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'if_no_location2', NULL, 'slide_information', NULL, 161, NULL, NULL, 'text', 'If_No_Location2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[same_slideloc] = ''0'' and [is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'parapieceloc_2', NULL, 'slide_information', NULL, 162, NULL, NULL, 'text', 'ParaPieceLoc_2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'is_there_metastatic_tumor', NULL, 'slide_information', NULL, 163, NULL, NULL, 'yesno', 'Is there Metastatic Tumor?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'metastatic_accnum', NULL, 'slide_information', NULL, 164, NULL, NULL, 'text', 'Metastatic_AccNum', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_met_quant', NULL, 'slide_information', NULL, 165, NULL, NULL, 'text', '5um_Met_Quant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_met_currentquant', NULL, 'slide_information', NULL, 166, NULL, NULL, 'text', '5um_Met_CurrentQuant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_met_quant', NULL, 'slide_information', NULL, 167, NULL, NULL, 'text', '10um_Met_Quant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_met_currentquant', NULL, 'slide_information', NULL, 168, NULL, NULL, 'text', '10um_Met_CurrentQuant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slideloc_metmetastatic', NULL, 'slide_information', NULL, 169, NULL, NULL, 'text', 'SlideLoc_Metmetastatic', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'parapieceloc_metastatic', NULL, 'slide_information', NULL, 170, NULL, NULL, 'text', 'ParaPieceLoc_Metastatic', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_metastatic_tumor] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'is_there_precancer', NULL, 'slide_information', NULL, 171, NULL, NULL, 'yesno', 'Is There Precancer?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'precancer_accnum', NULL, 'slide_information', NULL, 172, NULL, NULL, 'text', 'PreCancer_AccNum', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_precancer_quant', NULL, 'slide_information', NULL, 173, NULL, NULL, 'text', '5um_Precancer_Quant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'five_um_precancer_curquant', NULL, 'slide_information', NULL, 174, NULL, NULL, 'text', '5um_Precancer_CurrentQuant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_precancer_quant', NULL, 'slide_information', NULL, 175, NULL, NULL, 'text', '10um_Precancer_Quant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ten_um_precancer_curquant', NULL, 'slide_information', NULL, 176, NULL, NULL, 'text', '10um_Precancer_CurQuant', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slideloc_precancer', NULL, 'slide_information', NULL, 177, NULL, NULL, 'text', 'SlideLoc_Precancer', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'parapieceloc_precancer', NULL, 'slide_information', NULL, 178, NULL, NULL, 'text', 'ParaPieceLoc_Precancer', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[is_there_precancer] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slide_information_complete', NULL, 'slide_information', NULL, 179, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_ca_pos1', NULL, 'tma_information', 'TMA Information', 180, NULL, NULL, 'text', 'TMA_Ca_pos1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_ca_pos2', NULL, 'tma_information', NULL, 181, NULL, NULL, 'text', 'TMA_Ca_pos2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_nor_pos1', NULL, 'tma_information', NULL, 182, NULL, NULL, 'text', 'TMA_Nor_pos1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_nor_pos2', NULL, 'tma_information', NULL, 183, NULL, NULL, 'text', 'TMA_Nor_pos2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_preca_pos', NULL, 'tma_information', NULL, 184, NULL, NULL, 'text', 'TMA_ PreCa_pos1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_metastatic_pos', NULL, 'tma_information', NULL, 185, NULL, NULL, 'text', 'TMA Metastatic_pos1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'another_accnumber', NULL, 'tma_information', NULL, 186, NULL, NULL, 'yesno', 'Another_AccNumber?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_ca_pos3', NULL, 'tma_information', NULL, 187, NULL, NULL, 'text', 'TMA_Ca_pos3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_ca_pos4', NULL, 'tma_information', NULL, 188, NULL, NULL, 'text', 'TMA_Ca_pos4', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_nor_pos3', NULL, 'tma_information', NULL, 189, NULL, NULL, 'text', 'TMA_Nor_pos3', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_nor_pos4', NULL, 'tma_information', NULL, 190, NULL, NULL, 'text', 'TMA_Nor_pos4', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_preca_pos2', NULL, 'tma_information', NULL, 191, NULL, NULL, 'text', 'TMA_ PreCa_pos2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_metastatic_pos2', NULL, 'tma_information', NULL, 192, NULL, NULL, 'text', 'TMA Metastatic_pos2', NULL, NULL, NULL, NULL, NULL, 'soft_typed', '[another_accnumber] = ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'tma_information_complete', NULL, 'tma_information', NULL, 193, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pulling_date1', NULL, 'slide_tracking', 'Slide Tracking', 194, NULL, NULL, 'text', 'Pulling_Date1', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'forwhoseproject', NULL, 'slide_tracking', NULL, 195, NULL, NULL, 'text', 'ForWhoseProject1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'whichslidepulled1', NULL, 'slide_tracking', NULL, 196, NULL, NULL, 'text', 'WhichSlidePulled1', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pulled_quant1', NULL, 'slide_tracking', NULL, 197, NULL, NULL, 'text', 'Pulled_Quant1', NULL, NULL, 'float', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slide_tracking_complete', NULL, 'slide_tracking', NULL, 198, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains five data entry forms for collecting and tracking information for cancer tissue.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Multiple Surveys (classic)';
-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(survey_email_participant_field, project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, surveys_enabled, auto_inc_set, display_project_logo_institution) VALUES
('email',concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 1, 1, 0);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`,
`data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`,
`calendar`, `data_entry`, `participants`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 0, 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_surveys
INSERT INTO redcap_surveys (project_id, form_name, title, instructions, acknowledgement, question_by_section, question_auto_numbering, survey_enabled, save_and_return, logo, hide_title, view_results, min_responses_view_results, check_diversity_view_results, end_survey_redirect_url, survey_expiration) VALUES
(@project_id, 'participant_info_survey', 'Follow-Up Survey', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 1, NULL, 0, 0, 10, 0, NULL, NULL),
(@project_id, 'participant_morale_questionnaire', 'Patient Morale Questionnaire', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 1, NULL, 0, 0, 10, 0, NULL, NULL),
(@project_id, 'prescreening_survey', 'Pre-Screening Survey', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 0, NULL, 0, 0, 10, 0, NULL, NULL);
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'participant_id', NULL, 'prescreening_survey', 'Pre-Screening Survey', 1, NULL, NULL, 'text', 'Participant ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'dob', NULL, 'prescreening_survey', NULL, 2, NULL, 'Please fill out the information below.', 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'email', '1', 'prescreening_survey', NULL, 2.1, NULL, NULL, 'text', 'E-mail address', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'has_diabetes', NULL, 'prescreening_survey', NULL, 3, NULL, NULL, 'truefalse', 'I currently have Type 2 Diabetes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'consent', NULL, 'prescreening_survey', NULL, 4, NULL, NULL, 'checkbox', 'By checking this box, I certify that I am at least 18 years old and that I give my consent freely to participate in this study.', '1, I consent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prescreening_survey_complete', NULL, 'prescreening_survey', NULL, 5, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'participant_info_survey', 'Participant Info Survey', 6, NULL, 'As a participant in this study, please answer the questions below. Thank you!', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'participant_info_survey', NULL, 7, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'address', '1', 'participant_info_survey', NULL, 8, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'telephone_1', '1', 'participant_info_survey', NULL, 9, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'participant_info_survey', NULL, 11, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL, NULL, NULL),
(@project_id, 'race', NULL, 'participant_info_survey', NULL, 12, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'participant_info_survey', NULL, 13, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'participant_info_survey', NULL, 14, NULL, NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'participant_info_survey', NULL, 15, NULL, NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'participant_info_survey_complete', NULL, 'participant_info_survey', NULL, 16, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq1', NULL, 'participant_morale_questionnaire', 'Participant Morale Questionnaire', 17, NULL, 'As a participant in this study, please answer the questions below. Thank you!', 'select', 'On average, how many pills did you take each day last week?', '0, Less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, Over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq2', NULL, 'participant_morale_questionnaire', NULL, 18, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq3', NULL, 'participant_morale_questionnaire', NULL, 19, NULL, NULL, 'yesno', 'Would you be willing to discuss your experiences with a psychiatrist?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq4', NULL, 'participant_morale_questionnaire', NULL, 20, NULL, NULL, 'select', 'How open are you to further testing?', '0, Not open \\n 1, Undecided \\n 2, Very open', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'participant_morale_questionnaire_complete', NULL, 'participant_morale_questionnaire', NULL, 21, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', 'Completion Data (to be entered by study personnel only)', 22, NULL, 'This form is to be filled out by study personnel.', 'yesno', 'Has patient completed study?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 23, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 24, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_visit_4', NULL, 'completion_data', NULL, 25, NULL, NULL, 'text', 'Date of last visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'discharge_date_4', NULL, 'completion_data', NULL, 26, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'discharge_summary_4', NULL, 'completion_data', NULL, 27, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', NULL, 28, NULL, NULL, 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 29, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains three surveys and a data entry form. Includes a pre-screening survey followed by two follow-up surveys to capture information from the participant, and then a data entry form for final data to be entered by the study personnel. The project data is captured in classic data collection format.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Multiple Surveys (longitudinal)';
-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(survey_email_participant_field,project_name, app_title, status, repeatforms, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, surveys_enabled, auto_inc_set, display_project_logo_institution) VALUES
('email',concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 1, 1, 0);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`,
`data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`,
`calendar`, `data_entry`, `participants`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 0, 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create events --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 0, 0, 0, 'Initial Data', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'prescreening_survey');
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'participant_info_survey');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 1, 0, 0, 'Week 1', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'participant_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 8, 0, 0, 'Week 2', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'participant_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 15, 0, 0, 'Week 3', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'participant_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 22, 0, 0, 'Week 4', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'participant_morale_questionnaire');
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip, external_id) VALUES(@arm_id, 30, 0, 0, 'Final Data', NULL);
set @event_id = LAST_INSERT_ID();
INSERT INTO redcap_events_forms (event_id, form_name) VALUES(@event_id, 'completion_data');
-- Insert into redcap_surveys
INSERT INTO redcap_surveys (project_id, form_name, title, instructions, acknowledgement, question_by_section, question_auto_numbering, survey_enabled, save_and_return, logo, hide_title, view_results, min_responses_view_results, check_diversity_view_results, end_survey_redirect_url, survey_expiration) VALUES
(@project_id, 'participant_info_survey', 'Follow-Up Survey', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 1, NULL, 0, 0, 10, 0, NULL, NULL),
(@project_id, 'participant_morale_questionnaire', 'Patient Morale Questionnaire', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 1, NULL, 0, 0, 10, 0, NULL, NULL),
(@project_id, 'prescreening_survey', 'Pre-Screening Survey', '<p><strong>Please complete the survey below.</strong></p>\r\n<p>Thank you!</p>', '<p><strong>Thank you for taking the survey.</strong></p>\r\n<p>Have a nice day!</p>', 0, 1, 1, 0, NULL, 0, 0, 10, 0, NULL, NULL);
-- Insert into redcap_metadata --
INSERT INTO redcap_metadata (project_id, field_name, field_phi, form_name, form_menu_description, field_order, field_units, element_preceding_header, element_type, element_label, element_enum, element_note, element_validation_type, element_validation_min, element_validation_max, element_validation_checktype, branching_logic, field_req, edoc_id, edoc_display_img, custom_alignment, stop_actions, question_num, grid_name, misc) VALUES
(@project_id, 'participant_id', NULL, 'prescreening_survey', 'Pre-Screening Survey', 1, NULL, NULL, 'text', 'Participant ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'dob', NULL, 'prescreening_survey', NULL, 2, NULL, 'Please fill out the information below.', 'text', 'Date of birth', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'email', '1', 'prescreening_survey', NULL, 2.1, NULL, NULL, 'text', 'E-mail address', NULL, NULL, 'email', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'has_diabetes', NULL, 'prescreening_survey', NULL, 3, NULL, NULL, 'truefalse', 'I currently have Type 2 Diabetes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'consent', NULL, 'prescreening_survey', NULL, 4, NULL, NULL, 'checkbox', 'By checking this box, I certify that I am at least 18 years old and that I give my consent freely to participate in this study.', '1, I consent', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'prescreening_survey_complete', NULL, 'prescreening_survey', NULL, 5, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'first_name', '1', 'participant_info_survey', 'Participant Info Survey', 6, NULL, 'As a participant in this study, please answer the questions below. Thank you!', 'text', 'First Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'last_name', '1', 'participant_info_survey', NULL, 7, NULL, NULL, 'text', 'Last Name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'address', '1', 'participant_info_survey', NULL, 8, NULL, NULL, 'textarea', 'Street, City, State, ZIP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'telephone_1', '1', 'participant_info_survey', NULL, 9, NULL, NULL, 'text', 'Phone number', NULL, 'Include Area Code', 'phone', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ethnicity', NULL, 'participant_info_survey', NULL, 11, NULL, NULL, 'radio', 'Ethnicity', '0, Hispanic or Latino \\n 1, NOT Hispanic or Latino \\n 2, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, 'LH', NULL, NULL, NULL, NULL),
(@project_id, 'race', NULL, 'participant_info_survey', NULL, 12, NULL, NULL, 'select', 'Race', '0, American Indian/Alaska Native \\n 1, Asian \\n 2, Native Hawaiian or Other Pacific Islander \\n 3, Black or African American \\n 4, White \\n 5, More Than One Race \\n 6, Unknown / Not Reported', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'sex', NULL, 'participant_info_survey', NULL, 13, NULL, NULL, 'radio', 'Sex', '0, Female \\n 1, Male', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'height', NULL, 'participant_info_survey', NULL, 14, NULL, NULL, 'text', 'Height (cm)', NULL, NULL, 'float', '130', '215', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'weight', NULL, 'participant_info_survey', NULL, 15, NULL, NULL, 'text', 'Weight (kilograms)', NULL, NULL, 'int', '35', '200', 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'participant_info_survey_complete', NULL, 'participant_info_survey', NULL, 16, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq1', NULL, 'participant_morale_questionnaire', 'Participant Morale Questionnaire', 17, NULL, 'As a participant in this study, please answer the questions below concerning the PAST WEEK. Thank you!', 'select', 'On average, how many pills did you take each day last week?', '0, Less than 5 \\n 1, 5-10 \\n 2, 6-15 \\n 3, Over 15', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'pmq2', NULL, 'participant_morale_questionnaire', NULL, 18, NULL, NULL, 'select', 'Using the handout, which level of dependence do you feel you are currently at?', '0, 0 \\n 1, 1 \\n 2, 2 \\n 3, 3 \\n 4, 4 \\n 5, 5', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'choices', NULL, 'participant_morale_questionnaire', NULL, 19, NULL, 'Concerning the past week, how do you feel about ...', 'radio', 'The choices you made', '1, Not satisfied at all \\n 2, Somewhat dissatisfied \\n 3, Indifferent \\n 4, Somewhat satisfied \\n 5, Very satisfied', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'feelings_matrix', NULL),
(@project_id, 'life', NULL, 'participant_morale_questionnaire', NULL, 20, NULL, NULL, 'radio', 'Your life overall', '1, Not satisfied at all \\n 2, Somewhat dissatisfied \\n 3, Indifferent \\n 4, Somewhat satisfied \\n 5, Very satisfied', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'feelings_matrix', NULL),
(@project_id, 'job', NULL, 'participant_morale_questionnaire', NULL, 21, NULL, NULL, 'radio', 'Your job', '1, Not satisfied at all \\n 2, Somewhat dissatisfied \\n 3, Indifferent \\n 4, Somewhat satisfied \\n 5, Very satisfied', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'feelings_matrix', NULL),
(@project_id, 'family', NULL, 'participant_morale_questionnaire', NULL, 22, NULL, NULL, 'radio', 'Your family life', '1, Not satisfied at all \\n 2, Somewhat dissatisfied \\n 3, Indifferent \\n 4, Somewhat satisfied \\n 5, Very satisfied', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, 'feelings_matrix', NULL),
(@project_id, 'participant_morale_questionnaire_complete', NULL, 'participant_morale_questionnaire', NULL, 23, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'complete_study', NULL, 'completion_data', 'Completion Data (to be entered by study personnel only)', 24, NULL, 'This form is to be filled out by study personnel.', 'yesno', 'Has patient completed study?', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'withdraw_date', NULL, 'completion_data', NULL, 25, NULL, NULL, 'text', 'Put a date if patient withdrew study', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'withdraw_reason', NULL, 'completion_data', NULL, 26, NULL, NULL, 'select', 'Reason patient withdrew from study', '0, Non-compliance \\n 1, Did not wish to continue in study \\n 2, Could not tolerate the supplement \\n 3, Hospitalization \\n 4, Other', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_visit_4', NULL, 'completion_data', NULL, 27, NULL, NULL, 'text', 'Date of last visit', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'discharge_date_4', NULL, 'completion_data', NULL, 28, NULL, NULL, 'text', 'Date of hospital discharge', NULL, NULL, 'date_ymd', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'discharge_summary_4', NULL, 'completion_data', NULL, 29, NULL, NULL, 'select', 'Discharge summary in patients binder?', '0, No \\n 1, Yes', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'study_comments', NULL, 'completion_data', NULL, 30, NULL, NULL, 'textarea', 'Comments', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'completion_data_complete', NULL, 'completion_data', NULL, 31, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains three surveys and a data entry form. Includes a pre-screening survey followed by two follow-up surveys, one of which is a questionnaire takenly weekly to capture participant information longitudinally over a period of one month. The surveys are followed by a data entry form for final data to be entered by the study personnel. The project data is captured in longitudinal data collection format.',  '1');
-- SQL TO CREATE A REDCAP DEMO PROJECT --
set @project_title = 'Piping Example Project';
-- Obtain default values --
set @institution = (select value from redcap_config where field_name = 'institution' limit 1);
set @site_org_type = (select value from redcap_config where field_name = 'site_org_type' limit 1);
set @grant_cite = (select value from redcap_config where field_name = 'grant_cite' limit 1);
set @project_contact_name = (select value from redcap_config where field_name = 'project_contact_name' limit 1);
set @project_contact_email = (select value from redcap_config where field_name = 'project_contact_email' limit 1);
set @headerlogo = (select value from redcap_config where field_name = 'headerlogo' limit 1);
set @auth_meth = (select value from redcap_config where field_name = 'auth_meth_global' limit 1);
-- Create project --
INSERT INTO `redcap_projects`
(project_name, app_title, status, count_project, auth_meth, creation_time, production_time, institution, site_org_type, grant_cite, project_contact_name, project_contact_email, headerlogo, surveys_enabled, auto_inc_set, display_project_logo_institution) VALUES
(concat('redcap_demo_',LEFT(MD5(RAND()),6)), @project_title, 1, 0, @auth_meth, now(), now(), @institution, @site_org_type, @grant_cite, @project_contact_name, @project_contact_email, @headerlogo, 1, 1, 0);
set @project_id = LAST_INSERT_ID();
-- User rights --
INSERT INTO `redcap_user_rights` (`project_id`, `username`, `expiration`, `group_id`, `lock_record`, `data_export_tool`, `data_import_tool`,
`data_comparison_tool`, `data_logging`, `file_repository`, `double_data`, `user_rights`, `data_access_groups`, `graphical`, `reports`, `design`,
`calendar`, `data_entry`, `participants`, `data_quality_execute`) VALUES
(@project_id, 'site_admin', NULL, NULL, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, '', 0, 1);
-- Create single arm --
INSERT INTO redcap_events_arms (project_id, arm_num, arm_name) VALUES (@project_id, 1, 'Arm 1');
set @arm_id = LAST_INSERT_ID();
-- Create single event --
INSERT INTO redcap_events_metadata (arm_id, day_offset, offset_min, offset_max, descrip) VALUES (@arm_id, 0, 0, 0, 'Event 1');
set @event_id = LAST_INSERT_ID();
-- Insert into redcap_surveys
INSERT INTO redcap_surveys (project_id, form_name, title, instructions, acknowledgement, question_by_section, question_auto_numbering, survey_enabled, save_and_return, logo, hide_title) VALUES
(@project_id, 'survey', 'Example Survey to Demonstrate Piping', 'This survey will demonstrate some basic examples of the Piping feature in REDCap.', '<p style="font-size:14px;"><strong>[first_name], thank you for taking the survey.</strong></p><br><p>Have a nice day!</p>', 1, 0, 1, 0, NULL, 0);
-- Insert into redcap_metadata --
INSERT INTO `redcap_metadata` (`project_id`, `field_name`, `field_phi`, `form_name`, `form_menu_description`, `field_order`, `field_units`, `element_preceding_header`, `element_type`, `element_label`, `element_enum`, `element_note`, `element_validation_type`, `element_validation_min`, `element_validation_max`, `element_validation_checktype`, `branching_logic`, `field_req`, `edoc_id`, `edoc_display_img`, `custom_alignment`, `stop_actions`, `question_num`, `grid_name`, `misc`) VALUES
(@project_id, 'participant_id', NULL, 'survey', 'Example Survey', 1, NULL, NULL, 'text', 'Participant ID', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'first_name', NULL, 'survey', NULL, 2, NULL, 'Section 1', 'text', 'Your first name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'last_name', NULL, 'survey', NULL, 3, NULL, NULL, 'text', 'Your last name', NULL, NULL, NULL, NULL, NULL, 'soft_typed', NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'date_today', NULL, 'survey', NULL, 4, NULL, NULL, 'text', '[first_name], please enter today''s date?', NULL, NULL, 'date_mdy', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'ice_cream', NULL, 'survey', NULL, 5, NULL, NULL, 'radio', 'What is your favorite ice cream?', '1, Chocolate \\n 2, Vanilla \\n 3, Strawberry', NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'slider', NULL, 'survey', NULL, 6, NULL, 'Section 2', 'slider', 'How much do you like [ice_cream] ice cream?', 'Hate it | Indifferent | I love [ice_cream]!', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'number', NULL, 'survey', NULL, 7, NULL, NULL, 'text', 'Enter your favorite number', NULL, NULL, 'int', NULL, NULL, 'soft_typed', NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'calc', NULL, 'survey', NULL, 8, NULL, NULL, 'calc', 'Your favorite number above multiplied by 4 is:', '[number]*4', '[number] x 4 = [calc]', NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'confirm_name', NULL, 'survey', NULL, 9, NULL, NULL, 'radio', 'Please confirm your name', '0, [first_name] Harris \\n 1, [first_name] [last_name] \\n 2, [first_name] Taylor \\n 3, [first_name] deGrasse Tyson', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'confirm_name_error', NULL, 'survey', NULL, 10, NULL, NULL, 'descriptive', '<div class="red" style="padding:30px;"><b>ERROR:</b> Please try again!</div>', NULL, NULL, NULL, NULL, NULL, NULL, '[confirm_name] != '''' and [confirm_name] != ''1''', 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'review_answers', NULL, 'survey', NULL, 11, NULL, 'Review answers', 'descriptive', 'Review your answers below:\n\n<div style="font-size:14px;color:red;">Date: [date_today]\nName: [first_name] [last_name]\nFavorite ice cream: [ice_cream]\nFavorite number multiplied by 4: [calc]</div>\n\nIf all your responses look correct and you did not leave any blank, then click the Submit button below.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(@project_id, 'survey_complete', NULL, 'survey', NULL, 12, NULL, 'Form Status', 'select', 'Complete?', '0, Incomplete \\n 1, Unverified \\n 2, Complete', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL, NULL);

INSERT INTO `redcap_projects_templates` (`project_id`, `title`, `description`, `enabled`)
	VALUES (@project_id,  @project_title,  'Contains a single data collection instrument enabled as a survey, which contains questions to demonstrate the Piping feature.',  '1');