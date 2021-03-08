create or replace procedure intl_phone_number_render
    ( p_item   in            apex_plugin.t_item
    , p_plugin in            apex_plugin.t_plugin
    , p_param  in            apex_plugin.t_item_render_param
    , p_result in out nocopy apex_plugin.t_item_render_result 
    )
as
    l_item_name         varchar2(1000) := apex_plugin.get_input_name_for_page_item(false);
    p_item_label        varchar2(64);
    l_escaped_value     VARCHAR2(4000);
    l_idx_iso           pls_integer;
    EC_CONTEXT          apex_exec.t_context; -- excludeCountries : attribute_05
    OC_CONTEXT          apex_exec.t_context; -- onlyCountries : attribute_12
    PC_CONTEXT          apex_exec.t_context; -- prefferedCountries : attribute_14
    l_js_code varchar2(4000);
    l_auto_placeholder        p_item.attribute_01%type := p_item.attribute_03;
    l_geoIpLookup             p_item.attribute_01%type := nvl(p_item.attribute_09, p_plugin.attribute_03);
    l_preferred_countries     p_item.attribute_01%type := nvl(p_item.attribute_14, p_plugin.attribute_01);
    l_separate_dial_code_flag p_item.attribute_01%type := p_item.attribute_15;
    l_messages                p_item.attribute_01%type := p_plugin.attribute_04; -- for MLS messages
    
    l_crlf              char(2) := chr(13)||chr(10);

begin
    --debug
    if apex_application.g_debug then
        apex_plugin_util.debug_item_render
            ( p_plugin => p_plugin
            , p_item   => p_item
            , p_param  => p_param
            );
    end if;
    
    p_item_label := p_item.name||'_LABEL';
    l_escaped_value := apex_escape.html(p_param.value);
    htp.p('<input id="'||p_item.name||'" name="'||l_item_name||'" type="tel" placeholder="'||p_item.placeholder||'" class="text_field text_field apex-item-text '||p_item.element_css_classes||'" value="'||l_escaped_value||'" size="90%" />');
    
    
    
    apex_css.add (
    p_css => '#'||p_item_label||' { padding-left: '||(case when l_separate_dial_code_flag = 'Y' then '87' else '52' end)||'px; }',
    p_key => 'padding_label_'||p_item_label );
    
    
    --initialize the plugin via JavaScript
    apex_json.initialize_clob_output;
    apex_json.open_object;
    if p_item.attribute_01 is not null then
      apex_json.write('allowDropdown', (p_item.attribute_01 = 'Y'));
    end if;
    if p_item.attribute_02 is not null then
      apex_json.write('autoHideDialCode', (p_item.attribute_02 = 'Y'));
    end if;
    if l_auto_placeholder is not null then
      apex_json.write('autoPlaceholder', l_auto_placeholder);
    end if;
    apex_json.write('dropdownContainer', 'document.body');
    if p_item.attribute_05 is not null then
      ec_context := apex_exec.open_query_context(
        p_location          => apex_exec.c_location_local_db,
        p_sql_query         => p_item.attribute_05 );
      l_idx_iso := apex_exec.get_column_position(ec_context , 'ISO_ALPHA2');
      apex_json.open_array('excludeCountries');
      while apex_exec.next_row( ec_context ) loop
        apex_json.write(apex_exec.get_varchar2( ec_context, l_idx_iso ));
      end loop;
      apex_json.close_array;
    end if;
    if p_item.attribute_06 is not null then
      apex_json.write('formatOnDisplay', (p_item.attribute_06 = 'Y'));
    end if;
    apex_json.open_object('localizedCountries');
    apex_json.write('sn','Sénégal');
    apex_json.close_object;

    if p_item.attribute_12 is not null then
      oc_context := apex_exec.open_query_context(
        p_location          => apex_exec.c_location_local_db,
        p_sql_query         => p_item.attribute_12 );
      l_idx_iso := apex_exec.get_column_position(ec_context , 'ISO_ALPHA2');
      apex_json.open_array('onlyCountries');
      while apex_exec.next_row( oc_context ) loop
        apex_json.write(apex_exec.get_varchar2( oc_context, l_idx_iso ));
      end loop;
      apex_json.close_array;
    end if;
    
    if p_item.attribute_11 is not null then
      apex_json.write('nationalMode',(p_item.attribute_11 = 'Y'));
    end if;
    apex_json.write('hiddenInput', 'full_number');
    if l_preferred_countries is not null then
      apex_json.write('placeholderNumberType', p_item.attribute_13);
    end if;

    if l_preferred_countries is not null then
      pc_context := apex_exec.open_query_context(
        p_location          => apex_exec.c_location_local_db,
        p_sql_query         => l_preferred_countries );
      l_idx_iso := apex_exec.get_column_position(pc_context , 'ISO_ALPHA2');
      apex_json.open_array('preferredCountries');
      while apex_exec.next_row( pc_context ) loop
        apex_json.write(apex_exec.get_varchar2( pc_context, l_idx_iso ));
      end loop;
      apex_json.close_array;
    end if;

    if l_separate_dial_code_flag is not null then
      apex_json.write('separateDialCode',(l_separate_dial_code_flag = 'Y'));
    end if;
    if p_item.attribute_08 is not null then
      apex_json.write('initialCountry', p_item.attribute_08);
    end if;
    apex_json.write('geoIpLookup', '#geoIpLookup#');
    apex_json.write('utilsScript',p_plugin.file_prefix||'utils.js');
    apex_json.close_object;
    l_js_code := apex_json.get_clob_output;
    apex_json.free_output;
    
    l_js_code := replace(l_js_code,'"document.body"','document.body');

    l_js_code := replace(l_js_code,'"#geoIpLookup#"',l_geoIpLookup); -- plug this JS code with no escaping
   
    
    apex_debug.error('l_js_code === '||l_js_code);
    
    apex_javascript.add_onload_code(p_code => 
         'var input = document.getElementById("'||p_item.name||'");' || l_crlf
      || p_item.name||'_iti = window.intlTelInput(input,'|| l_js_code || ');' || l_crlf
      || p_item.name||'_iti.promise.then(function(){' || l_crlf -- wait for the iti item to be set before setting up the APEX item
      || '  $("#'|| p_item.name || '").sdIntrlPhones({' || l_crlf
      ||        apex_javascript.add_attribute('itemName', p_item.name, true, true) || l_crlf
      ||        apex_javascript.add_attribute('storageFormat', p_plugin.attribute_02, true, true) || l_crlf
      ||        apex_javascript.add_attribute('messages', l_messages, true, true) || l_crlf
      || '  });' || l_crlf
      || '});' -- close iti.promise
    );


end intl_phone_number_render;
/