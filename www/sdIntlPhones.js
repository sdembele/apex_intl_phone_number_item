

$.widget( "ui.sdIntrlPhones", {
 
  // Default options.
  options: {
     itemName: '',
     storageFormat: 1,
     messages: null,
     suffix: '_iti'
  },

  // Logging for "regular" text elements
  log: function() {
    var args = Array.prototype.join.call( arguments, ', ' );
    apex.debug.message(4, "sdIntrlPhones:", args);
  },

  // Enhanced log
  // accepts 2 objects for logging
  elog: function(p1,p2) {
    apex.debug.message(4, "sdIntrlPhones:", p1, p2);
  },


  _create: function() {
    var uiw = this;

    // Options are already merged and stored in this.options (or uiw.options)
    uiw.log("_create");
    uiw.log("itemName", uiw.options.itemName);
    uiw.log("suffix", uiw.options.suffix);
    uiw.log("storageFormat", uiw.options.storageFormat);

    uiw._values = {
        itiName:  uiw.options.itemName + uiw.options.suffix,
        messages: JSON.parse(uiw.options.messages)
    };

    uiw.log("itiName", uiw._values.itiName);
    uiw.elog("messages", uiw._values.messages);

    // Init APEX pageitem functions
    uiw._initApexItem();
  },


  _initApexItem: function () {
    var uiw = this;

    uiw.log("_initApexItem", "Registering with apex.item.create for " + uiw.options.itemName);
    // Set and get value via apex functions
    apex.item.create(uiw.options.itemName, {

       // setValue: function(pValue, pDisplayValue) {
       //    uiw.log( "apex.item.setValue", pValue, pDisplayValue);

       //    if (pDisplayValue || !pValue || pValue.length === 0) {
       //        // empty pValue, we should be done
       //        uiw._item$.val();
       //    } else {
       //        // NOT empty pValue
       //        if (!pDisplayValue) {
       //          pDisplayValue = uiw._getTL(uiw.options.lang);
       //        }

       //        uiw._item$.val(pDisplayValue);
       //    }

       // },

       getValue: function() {
          // get the number in the representation stored by storageFormat
          return window[uiw._values.itiName].getNumber(intlTelInputUtils.numberFormat[uiw.options.storageFormat]);
       },

       // If we ever use IG this will be useful
       // getPopupSelector: function() {
       //    return uiw._values.popupSEL;
       // },

       // If we ever use IG this will be useful
       // displayValueFor: function (pValue) {
       //    // The IG calls this code to set the initial display values
       //    uiw.log("apex.item.displayValueFor", pValue);
       //    if (pValue) {
       //    }
       //    return returnValue;
       // }

       getValidationMessage: function() {
         var message;
         if (!!window[uiw._values.itiName].getNumber() && window[uiw._values.itiName].isValidNumber()) {
           message = ""; // no error
         }
         else {
           switch (window[uiw._values.itiName].getValidationError()) {
             case intlTelInputUtils.validationError.IS_POSSIBLE:
             // sometimes we a is_possible combined with a !isValidNumber
             message = window[uiw._values.itiName].isValidNumber()?"":uiw._values.messages.INVALID;
             break;

             case intlTelInputUtils.validationError.INVALID_COUNTRY_CODE: 
             message = uiw._values.messages.INVALID_COUNTRY_CODE;
             break;

             case intlTelInputUtils.validationError.TOO_SHORT: 
             message = uiw._values.messages.TOO_SHORT;
             break;

             case intlTelInputUtils.validationError.TOO_LONG: 
             message = uiw._values.messages.TOO_LONG;
             break;

             case intlTelInputUtils.validationError.IS_POSSIBLE_LOCAL_ONLY:
             message = uiw._values.messages.IS_POSSIBLE_LOCAL_ONLY; // almost not an error
             break;

             case intlTelInputUtils.validationError.INVALID_LENGTH: 
             message = uiw._values.messages.INVALID_LENGTH;
             break;

             default:
             message = uiw._values.messages.INVALID;
             break;
          }
        }

         return message;


       },
       getValidity: function() {
         return {
//           badInput: window[uiw._values.itiName].isValidNumber(),
           customError: false,
           patternMismatch: false,
           rangeOverflow: false,
           rangeUnderflow: false,
           stepMismatch: false,
           tooLong: false,
           tooShort: false,
           typeMismatch: false,
           valid: !!window[uiw._values.itiName].getNumber()? window[uiw._values.itiName].isValidNumber(): true,
           valueMissing: false
          }
       }

    });

  },

  isValidNumber: function() {
    return window[uiw._values.itiName].isValidNumber();
  },
  
  getValidationError: function() {
    return window[uiw._values.itiName].getValidationError();
  }


});
