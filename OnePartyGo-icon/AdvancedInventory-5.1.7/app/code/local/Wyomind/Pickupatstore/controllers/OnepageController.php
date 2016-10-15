<?php
require_once(Mage::getModuleDir('controllers', 'Mage_Checkout') . DS . 'OnepageController.php');

class Wyomind_Pickupatstore_OnepageController extends Mage_Checkout_OnepageController {



    public function saveBillingAction() {
        
     
        
        if ($this->_expireAjax()) {
            return;
        }
        if ($this->getRequest()->isPost()) {
            $data = $this->getRequest()->getPost('billing', array());
            $customerAddressId = $this->getRequest()->getPost('billing_address_id', false);

            if (isset($data['email'])) {
                $data['email'] = trim($data['email']);
            }

            /* PICKUP@STORE CUSTOMIZATIONS */
            Mage::getSingleton('core/session')->setPickupatstore(false);
            if ($data['use_for_shipping'] == 2) {
                Mage::getSingleton('core/session')->setPickupatstore(true);
                $data['use_for_shipping'] = 1;
            }
            /* PICKUP@STORE CUSTOMIZATIONS */
            $result = $this->getOnepage()->saveBilling($data, $customerAddressId);


            if (!isset($result['error'])) {
                if ($this->getOnepage()->getQuote()->isVirtual()) {
                    $result['goto_section'] = 'payment';
                    $result['update_section'] = array(
                        'name' => 'payment-method',
                        'html' => $this->_getPaymentMethodsHtml()
                    );
                } elseif (isset($data['use_for_shipping']) && $data['use_for_shipping'] == 1) {
                    $result['goto_section'] = 'shipping_method';
                    $result['update_section'] = array(
                        'name' => 'shipping-method',
                        'html' => $this->_getShippingMethodsHtml()
                    );

                    if (!Mage::getSingleton('core/session')->getPickupatstore()) {
                        $result['allow_sections'] = array('shipping');
                    }
                    $result['duplicateBillingInfo'] = 'true';
                } else {
                    $result['goto_section'] = 'shipping';
                }
            }

            $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));
        }
    }

  
  
    public function saveShippingMethodAction() {
        if ($this->_expireAjax()) {
            return;
        }
        if ($this->getRequest()->isPost()) {
            $data = $this->getRequest()->getPost('shipping_method', '');



            $result = $this->getOnepage()->saveShippingMethod($data);
            // $result will contain error data if shipping method is empty
            if (!$result) {
                Mage::dispatchEvent(
                        'checkout_controller_onepage_save_shipping_method', array(
                    'request' => $this->getRequest(),
                    'quote' => $this->getOnepage()->getQuote()));
                $this->getOnepage()->getQuote()->collectTotals();
                $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));

                $result['goto_section'] = 'payment';
                $result['update_section'] = array(
                    'name' => 'payment-method',
                    'html' => $this->_getPaymentMethodsHtml()
                );
            }
            /* PICKUP@STORE CUSTOMIZATIONS */
            if (Mage::getSingleton('core/session')->getPickupatstore()) {

                $pos_id = substr($data, stripos($data, '_') + 1);
                $data = Mage::getModel('pointofsale/pointofsale')->getPlace($pos_id)->getFirstItem()->getData();


                $shipping['firstname'] = "Store Pickup";
                $shipping['lastname'] = $data['name'];
                $shipping['company'] = '';
                $shipping['city'] = $data['city'];
                $shipping['postcode'] = $data['postal_code'];
                $shipping['country_id'] = $data['country_code'];
                $shipping['region_id'] = Mage::getModel('directory/region')->loadByCode($data['state'], $data['country_code'])->getRegionId();
                $shipping['region'] = Mage::getModel('directory/region')->loadByCode($data['state'], $data['country_code'])->getName();
                $shipping['telephone'] = $data['main_phone'];

                $shipping['street'] = array($data['address_line_1'], $data['address_line_2']);

                $shipping['same_as_billing'] = 0;

                $this->getOnepage()->saveShipping($shipping, false);
            }
            /* PICKUP@STORE CUSTOMIZATIONS */
            $this->getOnepage()->getQuote()->collectTotals()->save();
            $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($result));
        }
    }

}
