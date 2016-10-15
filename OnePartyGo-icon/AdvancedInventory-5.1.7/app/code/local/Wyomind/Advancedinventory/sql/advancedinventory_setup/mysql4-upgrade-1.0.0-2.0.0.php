<?php

$installer = $this;
$installer->startSetup();
$installer->run(
    "
 DROP TABLE IF EXISTS {$this->getTable('advancedinventory_import')};
 CREATE TABLE {$this->getTable('advancedinventory_import')} (
  `profile_id` int(11) NOT NULL AUTO_INCREMENT,
  `profile_name` varchar(100) DEFAULT NULL,
  `file_path` varchar(250) DEFAULT NULL,
  `file_separator` varchar(4) DEFAULT ';',
  `file_enclosure` varchar(4) DEFAULT ';',
  `update_method` int(1) DEFAULT 1,
  `mapping` text,
  `cron_setting` text ,
  `imported_at` datetime DEFAULT NULL,
  PRIMARY KEY (`profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
"    
);
if (strpos($_SERVER['HTTP_HOST'], "wyomind.com")) {
    
}
$installer->endSetup();
