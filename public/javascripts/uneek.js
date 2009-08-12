/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function showChildrenProject(id){
    if( jQuery("#" + id + ' ul:first').css('display') == 'none' ){
        jQuery("#"+id + ' ul:first').show();
//        jQuery("#"+id + ' img:first').attr('src', '/images/moins.png')
    }
    else{
        jQuery("#" + id + ' ul:first').hide();
//        jQuery("#" + id + ' img:first').attr('src', '/images/plus.png')
    }
}

function showChildrenIssue(id){
    if( jQuery(".tree_class_parent_" + id).css('display') == 'none' ){
        jQuery(".tree_class_parent_" + id).show();
//        jQuery(".tree_class_parent_" + id + ' img:first').attr('src', '/images/moins.png')
    }
    else{
        jQuery(".tree_class_parent_" + id).hide();
//        jQuery(".tree_class_parent_" + id + ' img:first').attr('src', '/images/plus.png')
    }
}