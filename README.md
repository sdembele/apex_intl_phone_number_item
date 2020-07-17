# apex_intl_phone_number_item

---

# International Phone Number Input
Oracle APEX plug-in for entering and validating international telephone numbers. It adds a flag dropdown to any input, detects the user's country, displays a relevant placeholder and provides formatting/validation methods.
It based on http://intl-tel-input.com works


## Demo and Examples
You can view a live demo and some examples of how to use the various options here: https://apex.oracle.com/pls/apex/sdembele/r/79291/intl-phone-number, or try it for yourself using the included demo.html.


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
  .iti__flag {background-image: url("#APP_IMAGES#flags.png");}

  @media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
    .iti__flag {background-image: url("#APP_IMAGES#flags@2x.png");}
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
