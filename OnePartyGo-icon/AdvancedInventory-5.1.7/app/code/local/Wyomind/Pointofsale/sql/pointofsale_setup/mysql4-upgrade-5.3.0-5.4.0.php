<?php

$installer = $this;

$installer->startSetup();

$installer->run("ALTER TABLE {$this->getTable('pointofsale')} CHANGE `status` visible_google_map INT(4) NOT NULL DEFAULT '1'; ");
$installer->run("ALTER TABLE {$this->getTable('pointofsale')} ADD visible_product_page INT(4) NOT NULL DEFAULT '1'; ");
$installer->run("ALTER TABLE {$this->getTable('pointofsale')} ADD visible_checkout INT(4) NOT NULL DEFAULT '1'; ");
$installer->run("UPDATE {$this->getTable('pointofsale')} set visible_product_page = visible_google_map, visible_checkout=visible_google_map; ");


$installer->endSetup();