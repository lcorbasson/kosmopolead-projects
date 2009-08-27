;(function($){
/**
 * jqGrid English Translation
 * Tony Tomov tony@trirand.com
 * http://trirand.com/blog/ 
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
**/
$.jgrid = {};

$.jgrid.defaults = {
	recordtext: "View {0} - {1} of {2}",
    emptyrecords: "No records to view",
	loadtext: "Loading...",
	pgtext : "Page {0} of {1}",
    pagerpos: 'center', // should be in grid param not here
    recordpos: 'right' // this too
};
$.jgrid.search = {
    caption: "Rechercher...",
    Find: "Trouver",
    Reset: "Réinitialiser",
    odata : ['égal', 'différent', 'inférieur', 'inférieur ou égal','supérieur','supérieur ou égal', 'commence par','se termine par','contient' ]
};
$.jgrid.edit = {
    addCaption: "Ajouter un enregistrement",
    editCaption: "Editer un enregistrement",
    bSubmit: "Valider",
    bCancel: "Annuler",
	bClose: "Fermer",
    processData: "Processing...",
    msg: {
        required:"Ce champ est obligatoire",
        number:"Veuillez entrer un nombre valide",
        minValue:"value must be greater than or equal to ",
        maxValue:"value must be less than or equal to",
        email: "is not a valid e-mail",
        integer: "Please, enter valid integer value",
		date: "Veuillez entrer une date valide"
    }
};
$.jgrid.del = {
    caption: "Supprimer",
    msg: "Supprimer la ligne sélectionnée ?",
    bSubmit: "Supprimer",
    bCancel: "Annuler",
    processData: "Processing..."
};
$.jgrid.nav = {
	edittext: "",
    edittitle: "Editer la ligne sélectionnée",
	addtext:"",
    addtitle: "Add new row",
    deltext: "",
    deltitle: "Delete selected row",
    searchtext: "",
    searchtitle: "Find records",
    refreshtext: "",
    refreshtitle: "Reload Grid",
    alertcap: "Avertissement",
    alerttext: "Veuillez sélectionner un enregistrement"
};
// setcolumns module
$.jgrid.col ={
    caption: "Show/Hide Columns",
    bSubmit: "Submit",
    bCancel: "Cancel"	
};
$.jgrid.errors = {
	errcap : "Error",
	nourl : "No url is set",
	norecords: "No records to process",
    model : "Length of colNames <> colModel!"
};
$.jgrid.formatter = {
	integer : {thousandsSeparator: " ", defaulValue: 0},
	number : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, defaulValue: 0},
	currency : {decimalSeparator:".", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix:"", defaulValue: 0},
	date : {
		dayNames:   [
			"Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat",
			"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
		],
		monthNames: [
			"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
			"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
		],
		AmPm : ["am","pm","AM","PM"],
		S: function (j) {return j < 11 || j > 13 ? ['st', 'nd', 'rd', 'th'][Math.min((j - 1) % 10, 3)] : 'th'},
		srcformat: 'Y-m-d',
		newformat: 'd/m/Y',
		masks : {
            ISO8601Long:"Y-m-d H:i:s",
            ISO8601Short:"Y-m-d",
            ShortDate: "n/j/Y",
            LongDate: "l, F d, Y",
            FullDateTime: "l, F d, Y g:i:s A",
            MonthDay: "F d",
            ShortTime: "g:i A",
            LongTime: "g:i:s A",
            SortableDateTime: "Y-m-d\\TH:i:s",
            UniversalSortableDateTime: "Y-m-d H:i:sO",
            YearMonth: "F, Y"
        },
        reformatAfterEdit : false
	},
	baseLinkUrl: '',
	showAction: 'show'
};
// US
// GB
// CA
// AU
})(jQuery);
