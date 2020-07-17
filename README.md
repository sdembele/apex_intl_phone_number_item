# apex_intl_phone_number_item
#### IMPORTANT: since v14 we have removed the jQuery dependency. See below for how to initialise and use the plugin with pure JavaScript. If you want to stick with the jQuery version, there is now a separate jQuery wrapped version.
---

# International Phone Number Input
Oracle APEX plug-in for entering and validating international telephone numbers. It adds a flag dropdown to any input, detects the user's country, displays a relevant placeholder and provides formatting/validation methods.
It based on http://intl-tel-input.com works

## Table of Contents

- [Demo and Examples](#demo-and-examples)
- [Features](#features)
- [Browser Compatibility](#browser-compatibility)
- [Getting Started](#getting-started)
- [Recommended Usage](#recommended-usage)
- [Options](#initialisation-options)
- [Public Methods](#public-methods)
- [Static Methods](#static-methods)
- [Events](#events)
- [Utilities Script](#utilities-script)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Attributions](#attributions)


## Demo and Examples
You can view a live demo and some examples of how to use the various options here: http://intl-tel-input.com, or try it for yourself using the included demo.html.


## Features
* Automatically select the user's current country using an IP lookup
* Automatically set the input placeholder to an example number for the selected country
* Navigate the country dropdown by typing a country's name, or using up/down keys
* Handle phone number extensions
* The user types their national number and the plugin gives you the full standardized international number
* Full validation, including specific error types
* Retina flag icons
* Lots of initialisation options for customisation, as well as public methods for interaction

## Getting Started
1. Download the plug-ig

2. Download and upload to the Static Application Files the flags.png and flags@2x.png

3. Override the path to flags.png in your global page or specific page
  ```css
  .iti__flag {background-image: url("path/to/flags.png");}

  @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
    .iti__flag {background-image: url("path/to/flags@2x.png");}
  }
  ```
  ## Tips
You can always get the full international number (including country code) using `getNumber`, then you only have to store that one string in your database (you don't have to store the country separately), and then the next time you initialise the plugin with that number it will automatically set the country and format it according to the options you specify (e.g. if you enable `nationalMode` it will automatically remove the international dial code for you).


## Plug-in Attributes
Note: any options that take country codes should be [ISO 3166-1 alpha-2](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) codes  

**allowDropdown**  
Whether or not to allow the dropdown. If disabled, there is no dropdown arrow, and the selected flag is not clickable.

**autoHideDialCode**  
If there is just a dial code in the input: remove it on blur or submit. This is to prevent just a dial code getting submitted with the form. Requires `nationalMode` to be set to `false`.

**autoPlaceholder**  
Set the input's placeholder to an example number for the selected country, and update it if the country changes. You can specify the number type using the `placeholderNumberType` option. By default it is set to `"polite"`, which means it will only set the placeholder if the input doesn't already have one. You can also set it to `"aggressive"`, which will replace any existing placeholder, or `"off"`.

**customContainer**  
Type: `String` Default: `""`  
Additional classes to add to the parent div.

**excludeCountries**   
In the dropdown, display all countries except the ones you specify here.
```sql 
select iso_alpha2 from exclude_countries_tab
```
**formatOnDisplay**  
Format the input value (according to the `nationalMode` option) during initialisation, and on `setNumber`.

**initialCountry**  
Set the initial country selection by specifying its country code.
If you leave `initialCountry` blank, it will default to the first country in the list.

**nationalMode**  
Allow users to enter national numbers (and not have to think about international dial codes). Formatting, validation and placeholders still work. Then you can use `getNumber` to extract a full international number

**onlyCountries**  
In the dropdown, display only the countries you specify
```sql 
select iso_alpha2 from only_countries_tab
```


**preferredCountries**
Specify the countries to appear at the top of the list.
```sql 
select iso_alpha2 from preferred_countries_tab
```

**separateDialCode**   
Display the country dial code next to the selected flag so it's not part of the typed number.

## Public Methods
In these examples, `iti` refers to the plugin instance which gets returned when you initialise the plugin e.g. `var iti = intlTelInput(input)`

**destroy**  
Remove the plugin from the input, and unbind any event listeners.  
```js
iti.destroy();
```

**getExtension**  
Get the extension from the current number. Requires the `utilsScript` option.
```js
var extension = iti.getExtension();
```
Returns a string e.g. if the input value was `"(702) 555-5555 ext. 1234"`, this would return `"1234"`

**getNumber**  
Get the current number in the given format (defaults to [E.164 standard](http://en.wikipedia.org/wiki/E.164)). The different formats are available in the enum `intlTelInputUtils.numberFormat` - which you can see [here](https://github.com/jackocnr/intl-tel-input/blob/master/src/js/utils.js#L109). Requires the `utilsScript` option. _Note that even if `nationalMode` is enabled, this can still return a full international number. Also note that this method expects a valid number, and so should only be used after validation._  
```js
var number = iti.getNumber();
// or
var number = iti.getNumber(intlTelInputUtils.numberFormat.E164);
```
Returns a string e.g. `"+17024181234"`

**getNumberType**  
Get the type (fixed-line/mobile/toll-free etc) of the current number. Requires the `utilsScript` option.  
```js
var numberType = iti.getNumberType();
```
Returns an integer, which you can match against the [various options](https://github.com/jackocnr/intl-tel-input/blob/master/src/js/utils.js#L119) in the global enum `intlTelInputUtils.numberType` e.g.  
```js
if (numberType === intlTelInputUtils.numberType.MOBILE) {
    // is a mobile number
}
```
_Note that in the US there's no way to differentiate between fixed-line and mobile numbers, so instead it will return `FIXED_LINE_OR_MOBILE`._

**getSelectedCountryData**  
Get the country data for the currently selected flag.  
```js
var countryData = iti.getSelectedCountryData();
```
Returns something like this:
```js
{
  name: "Afghanistan (‫افغانستان‬‎)",
  iso2: "af",
  dialCode: "93"
}
```

**getValidationError**  
Get more information about a validation error. Requires the `utilsScript` option.  
```js
var error = iti.getValidationError();
```
Returns an integer, which you can match against the [various options](https://github.com/jackocnr/intl-tel-input/blob/master/src/js/utils.js#L153) in the global enum `intlTelInputUtils.validationError` e.g.  
```js
if (error === intlTelInputUtils.validationError.TOO_SHORT) {
    // the number is too short
}
```

**isValidNumber**  
Validate the current number - [see example](http://intl-tel-input.com/node_modules/intl-tel-input/examples/gen/is-valid-number.html). Expects an internationally formatted number (unless `nationalMode` is enabled). If validation fails, you can use `getValidationError` to get more information. Requires the `utilsScript` option. Also see `getNumberType` if you want to make sure the user enters a certain type of number e.g. a mobile number.  
```js
var isValid = iti.isValidNumber();
```
Returns: `true`/`false`

**setCountry**  
Change the country selection (e.g. when the user is entering their address).  
```js
iti.setCountry("gb");
```

**setNumber**  
Insert a number, and update the selected flag accordingly. _Note that if `formatOnDisplay` is enabled, this will attempt to format the number according to the `nationalMode` option._  
```js
iti.setNumber("+447733123456");
```

**setPlaceholderNumberType**  
Change the placeholderNumberType option.
```js
iti.setPlaceholderNumberType("FIXED_LINE");
```

