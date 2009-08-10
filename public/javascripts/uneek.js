/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function showChildrenProject(id){
    if( jQuery(".tree_id_parent_" + id).css('display') == 'none' ){
        jQuery(".tree_id_parent_" + id).show();
        jQuery(".tree_id_parent_" + id + ' img:first').attr('src', 'images/moins.png')
    }
    else{
        jQuery(".tree_id_parent_" + id).hide();
        jQuery(".tree_id_parent_" + id + ' img:first').attr('src', 'images/plus.png')
    }
}