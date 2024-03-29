/* Change the preference of the user for bloc filter */
function change_state_filter(id){
    jQuery.get("/users/change_filter_bloc_state/"+id);
}

jQuery().ready(function() {

    jQuery("#communities_button").click(function() {
      jQuery(".community_menu_item").slideToggle();
    });
    
});


/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

//TREE TASK AND PROJECTS
function initialize_toggle(toggle) {
    //set effect from select menu value
    jQuery(".toggle_"+toggle).click(function() {
        if (jQuery(".toggle_"+toggle).hasClass("open")){
          one_show = false;
          jQuery(".toggle_"+toggle).removeClass("open");
          jQuery(".toggle_"+toggle).addClass("close");
          jQuery('#effect_'+toggle).removeClass("display");
          jQuery('#effect_'+toggle).addClass("hidden");
          jQuery(".effect").each(function(i){
              if (jQuery(this).hasClass("display") && one_show == false){
                 one_show = false;
              }
          });
          if (one_show == true){
               jQuery('.buttons').removeClass("hidden");
               jQuery('.buttons').addClass("display");
          }
          else{
               jQuery('.buttons').removeClass("display");
                jQuery('.buttons').addClass("hidden");
          }
      }
        else {
           jQuery(".toggle_"+toggle).removeClass("close");
           jQuery(".toggle_"+toggle).addClass("open");
           jQuery('#effect_'+toggle).removeClass("hidden");
           jQuery('#effect_'+toggle).addClass("display");
           jQuery('.buttons').removeClass("hidden");
           jQuery('.buttons').addClass("display");
        }
        return false;
    });

}

function showChildrenProject(id){
    
    if( jQuery("#" + id + ' ul:first').css('display') == 'none' ){
        jQuery("#"+id + ' ul:first').show();
        jQuery("#"+id + ' img:first').attr('src', '/images/collapse.png')
    }
    else{
        jQuery("#" + id + ' ul:first').hide();
        jQuery("#" + id + ' img:first').attr('src', '/images/expand.png')
    }
}

function showChildrenIssue(id){
   
    if( jQuery(".tree_class_parent_" + id).css('display') == 'none' ){
        jQuery(".tree_class_parent_" + id).show();       
        jQuery("tr#"+id+' td.checkbox:first .tree_img').attr('src', '/images/collapse.png')
        jQuery("tr#"+id).addClass('active');
    }
    else{
        jQuery(".tree_class_parent_" + id).hide();
        jQuery("tr#"+id+' td.checkbox:first .tree_img').attr('src', '/images/expand.png')
        jQuery("tr#"+id).removeClass('active');
    }
}



//TOGGLE
function runEffect(effect){ 
   //get effect type from
			var selectedEffect = jQuery('#effectTypes').val();

			//most effect types need no options passed by default
			var options = {};
			//check if it's scale, transfer, or size - they need options explicitly set
			if(selectedEffect == 'scale'){  options = {percent: 0}; }
			else if(selectedEffect == 'size'){ options = { to: {width: 200,height: 60} }; }

			//run the effect
			jQuery("#"+effect).toggle(selectedEffect,options,500);
}


function activeProjectMenu(id){
    jQuery(".projects_list li a").removeClass("active");
    jQuery("#projects_id_"+id+" a:first").addClass("active");
}


function initialize_funding_grid(url,edit_url){   
     jQuery("#funding_fields_list").jqGrid({
            url:url,
            datatype: "json",
            colNames:["AAP", "Financeur","Correspondant financeur","Montant demandé","Type","Date accord","Montant accordé","Date libération","Montant libéré"],
            colModel:[
                {name:'aap',index:'aap',width:80, resizable:false,sortable:true, align:"center", editable:true},
                {name:'backer',index:'backer',width:100, resizable:false, sortable:true, editable:true, align:"center"},
                {name:'backer_correspondent',index:'backer_correspondent', resizable:false, sortable:true, editable:true, align:"center"},
                {name:'asked_amount',index:'asked_amount',width:100, resizable:true, sortable:false, editable:true, align:"right" },
                {name:'funding_type',index:'type', width:100,resizable:false, sortable:true, editable:true, align:"center"},
                {name:'agreed_on',index:'agreed_on', resizable:false, sortable:true, editable:true, align:"center",
                   editoptions:{size:12}},
                {name:'asked_amount',index:'asked_amount',width:100, resizable:false, sortable:true, editable:true, align:"right"},
                {name:'released_on',index:'released_on', resizable:false, sortable:true, editable:true, align:"center"
                     
                },
                {name:'released_amount',index:'released_amount',width:100, resizable:false, sortable:true, editable:true, align:"right"}],
            multiselect: false,
            multiboxonly:true,
            pager:jQuery("#pager"),
            rowNum:40, //Nombre d'enregistrements visibles par défaut
            rowList:[10,20,50],          
            height:"auto",
            loadtext: "Chargement de la liste...",
            pgtext : "Page {0} sur {1}",
            emptyrecords: "Aucune ligne",
            viewrecords: true //Affichage du nombre d'enregistrements courants  
        }).navGrid('#pager', {view:true}, //options        
        {reloadAfterSubmit:true,jqModal:false, closeOnEscape:true}, // del options
        {closeOnEscape:true}, // search options
        {navkeys: [true,38,40], height:250,jqModal:false,closeOnEscape:true} // view options
        );

    

            jQuery(".jqgrid_div div").width("100%");
            jQuery(".jqgrid_div table").width("100%");
            jQuery(".jqgrid_div .ui-jqgrid-titlebar").css("padding-left",0);
            jQuery(".jqgrid_div .ui-jqgrid-titlebar").css("padding-right",0);
            jQuery(".jqgrid_div .loading").width("20%");

}

function initialize_simple_funding_grid(url,edit_url){
     jQuery("#funding_fields_list").jqGrid({
            url:url,
            datatype: "json",
            colNames:["AAP", "Financeur","Correspondant financeur","Montant demandé","Type","Date accord","Montant accordé","Date libération","Montant libéré",""],
            colModel:[
                {name:'aap',index:'aap',width:80, resizable:false,sortable:true, align:"center", editable:true},
                {name:'backer',index:'backer',width:100, resizable:false, sortable:true, editable:true, align:"center"},
                {name:'backer_correspondent',index:'backer_correspondent', resizable:false, sortable:true, editable:true, align:"center"},
                {name:'asked_amount',index:'asked_amount',width:100, resizable:true, sortable:false, editable:true, align:"right" },
                {name:'type',index:'type', width:100,resizable:false, sortable:true, editable:true, align:"center"},
                {name:'agreed_on',index:'agreed_on', resizable:false, sortable:true, editable:true, align:"center",
                   editoptions:{size:12//,
//                        dataInit:function(el){
//                            jQuery(el).datepicker({dateFormat:'yy-mm-dd'});
//                        },
//                        defaultValue: function(){
//                            var currentTime = new Date();
//                            var month = parseInt(currentTime.getMonth() + 1);
//                            month = month <= 9 ? "0"+month : month;
//                            var day = currentTime.getDate();
//                            day = day <= 9 ? "0"+day : day;
//                            var year = currentTime.getFullYear();
//                            return year+"-"+month + "-"+day;
//                        }
                    }
                },
                {name:'agreed_amount',index:'agreed_amount',width:100, resizable:false, sortable:true, editable:true, align:"right"},
                {name:'released_on',index:'released_on', resizable:false, sortable:true, editable:true, align:"center"

                },
                {name:'released_amount',index:'released_amount',width:100, resizable:false, sortable:true, editable:true, align:"right"},
                {name:'delete',index:'delete',width:100, resizable:false, sortable:false, editable:true, align:"right"}
                ],

            multiselect: false,
            multiboxonly:true,
            pager:jQuery("#pager"),
            rowNum:40, //Nombre d'enregistrements visibles par défaut
            rowList:[10,20,50],
            height:"auto",
            loadtext: "Chargement de la liste...",
            pgtext : "Page {0} sur {1}",
            emptyrecords: "Aucune ligne",
            viewrecords: true, //Affichage du nombre d'enregistrements courants
            editurl:edit_url
        });



            jQuery(".jqgrid_div div").width("100%");
            jQuery(".jqgrid_div table").width("100%");
            jQuery(".jqgrid_div .ui-jqgrid-titlebar").css("padding-left",0);
            jQuery(".jqgrid_div .ui-jqgrid-titlebar").css("padding-right",0);
            jQuery(".jqgrid_div .loading").width("20%");

}

function sector_activity_show(t){
    jQuery.ajax({dataType:'script', url:'sector_translations', data:'local=' + t.value,type: "get", success: function(msg){eval(msg)}});
}

function initialize_autocomplete_author_project(project){    
    jQuery("#field_autocomplete_author").autocomplete("/projects/list_members_community/",{
        matchContains: false
   });
     jQuery("#field_autocomplete_author").result(function(event, data, formatted) {
        jQuery("#project_author_id").val(data[1]);         
        user_id = jQuery("#project_author_id").val();
         jQuery.ajax({
                type: "get",
                url: "projects/list_partners?user_id="+user_id,
                success: function(msg){
                    eval(msg)  ;
                }
            });
    });
    jQuery("#field_autocomplete_author").change(function() {
        jQuery("#project_author_id").val(jQuery("#field_autocomplete_author").val());
       
    });

}

function initialize_autocomplete_watcher_project(project){
    jQuery("#field_autocomplete_watcher").autocomplete("/projects/list_members_community/",{
        matchContains: false
   });
     jQuery("#field_autocomplete_watcher").result(function(event, data, formatted) {
        jQuery("#project_watcher_id").val(data[1]);


    });
}


function initialize_autocomplete_designer_project(project){
    jQuery("#field_autocomplete_designer").autocomplete("/projects/list_members_community/",{
        matchContains: false
   });
   jQuery("#field_autocomplete_designer").result(function(event, data, formatted) {
        jQuery("#project_designer_id").val(data[1]);
    });
}


function initialize_autocomplete_partner_project(project){
    jQuery("#field_autocomplete_partner").autocomplete("/projects/list_partners_community/");
     jQuery("#field_autocomplete_partner").result(function(event, data, formatted) {
        jQuery("#partner_id").val(data[1]);
        partner_id = jQuery("#partner_id").val();
         jQuery.ajax({
                type: "get",
                url: "projects/list_partnerships?partner_id="+partner_id,
                success: function(msg){
                    eval(msg)  ;
                }
            });
    });
    jQuery("#field_autocomplete_partner").change(function() {
        jQuery("#partner_id").val(jQuery("#field_autocomplete_partner").val());

    });
};

function initialize_autocomplete_funding(label,field){
    jQuery("#"+field).autocomplete("/funding_lines/render_data_uses?field="+label,{
          matchContains: false
    });
};
