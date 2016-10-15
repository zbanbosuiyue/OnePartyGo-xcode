<?php

$installer = $this;
$installer->startSetup();
$setup = new Mage_Sales_Model_Resource_Setup('core_setup');

$installer->run("ALTER TABLE {$this->getTable('sales_flat_quote')} 
  ADD  `shipping_description` varchar(1500) NULL;
");
$installer->getConnection()->addColumn($installer->getTable('sales_flat_quote'), 'pickup_hour', 'varchar(255) NULL DEFAULT NULL');
$setup->addAttribute('quote', 'pickup_hour', array('type' => 'static', 'visible' => false));

$installer->getConnection()->addColumn($installer->getTable('sales_flat_quote'), 'pickup_day', 'varchar(255) NULL DEFAULT NULL');
$setup->addAttribute('quote', 'pickup_day', array('type' => 'static', 'visible' => false));

$installer->run("ALTER TABLE {$this->getTable('sales_flat_order')} 
  MODIFY  `shipping_description` varchar(1500);
");

$installer->getConnection()->addColumn($installer->getTable('sales_flat_order'), 'pickup_hour', 'varchar(255) NULL DEFAULT NULL');
$setup->addAttribute('order', 'pickup_hour', array('type' => 'static', 'visible' => false));

$installer->getConnection()->addColumn($installer->getTable('sales_flat_order'), 'pickup_day', 'varchar(255) NULL DEFAULT NULL');
$setup->addAttribute('order', 'pickup_day', array('type' => 'static', 'visible' => false));

$installer->endSetup();
