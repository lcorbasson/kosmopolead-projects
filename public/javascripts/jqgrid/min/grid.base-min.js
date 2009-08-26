/*
 * jqGrid  3.4.2 - jQuery Grid
 * Copyright (c) 2008, Tony Tomov, tony@trirand.com
 * Dual licensed under the MIT and GPL licenses
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 * Date: 2009-03-01 rev 82
 */
;(function(b){b.fn.jqGrid=function(x){x=b.extend(true,{url:"",height:150,page:1,rowNum:20,records:0,pager:"",pgbuttons:true,pginput:true,colModel:[],rowList:[],colNames:[],sortorder:"asc",sortname:"",datatype:"xml",mtype:"GET",imgpath:"",sortascimg:"sort_asc.gif",sortdescimg:"sort_desc.gif",firstimg:"first.gif",previmg:"prev.gif",nextimg:"next.gif",lastimg:"last.gif",altRows:true,selarrrow:[],savedRow:[],shrinkToFit:true,xmlReader:{},jsonReader:{},subGrid:false,subGridModel:[],lastpage:0,lastsort:0,selrow:null,beforeSelectRow:null,onSelectRow:null,onSortCol:null,ondblClickRow:null,onRightClickRow:null,onPaging:null,onSelectAll:null,loadComplete:null,gridComplete:null,loadError:null,loadBeforeSend:null,afterInsertRow:null,beforeRequest:null,onHeaderClick:null,viewrecords:false,loadonce:false,multiselect:false,multikey:false,editurl:null,search:false,searchdata:{},caption:"",hidegrid:true,hiddengrid:false,postData:{},userData:{},treeGrid:false,treeGridModel:'nested',treeReader:{},ExpandColumn:null,tree_root_level:0,prmNames:{page:"page",rows:"rows",sort:"sidx",order:"sord"},sortclass:"grid_sort",resizeclass:"grid_resize",forceFit:false,gridstate:"visible",cellEdit:false,cellsubmit:"remote",nv:0,loadui:"enable",toolbar:[false,""],scroll:false,multiboxonly:false,scrollrows:false,deselectAfterSort:true},b.jgrid.defaults,x||{});var k={headers:[],cols:[],dragStart:function(c,d){this.resizing={idx:c,startX:d};this.hDiv.style.cursor="e-resize"},dragMove:function(c){if(this.resizing){var d=c-this.resizing.startX,f=this.headers[this.resizing.idx],h=f.width+d,i,j;if(h>25){if(x.forceFit===true){i=this.headers[this.resizing.idx+x.nv];j=i.width-d;if(j>25){f.el.style.width=h+"px";f.newWidth=h;this.cols[this.resizing.idx].style.width=h+"px";i.el.style.width=j+"px";i.newWidth=j;this.cols[this.resizing.idx+x.nv].style.width=j+"px";this.newWidth=this.width}}else{f.el.style.width=h+"px";f.newWidth=h;this.cols[this.resizing.idx].style.width=h+"px";this.newWidth=this.width+d;b('table:first',this.bDiv).css("width",this.newWidth+"px");b('table:first',this.hDiv).css("width",this.newWidth+"px");this.hDiv.scrollLeft=this.bDiv.scrollLeft}}}},dragEnd:function(){this.hDiv.style.cursor="default";if(this.resizing){var c=this.resizing.idx;this.headers[c].width=this.headers[c].newWidth||this.headers[c].width;this.cols[c].style.width=this.headers[c].newWidth||this.headers[c].width;if(x.forceFit===true){this.headers[c+x.nv].width=this.headers[c+x.nv].newWidth||this.headers[c+x.nv].width;this.cols[c+x.nv].style.width=this.headers[c+x.nv].newWidth||this.headers[c+x.nv].width}if(this.newWidth){this.width=this.newWidth}this.resizing=false}},scrollGrid:function(){if(x.scroll===true){var c=this.bDiv.scrollTop;if(c!=this.scrollTop){this.scrollTop=c;if((this.bDiv.scrollHeight-c-b(this.bDiv).height())<=0){if(parseInt(x.page,10)+1<=parseInt(x.lastpage,10)){x.page=parseInt(x.page,10)+1;this.populate()}}}}this.hDiv.scrollLeft=this.bDiv.scrollLeft}};b.fn.getGridParam=function(c){var d=this[0];if(!d.grid){return}if(!c){return d.p}else{return d.p[c]?d.p[c]:null}};b.fn.setGridParam=function(c){return this.each(function(){if(this.grid&&typeof(c)==='object'){b.extend(true,this.p,c)}})};b.fn.getDataIDs=function(){var d=[];this.each(function(){b(this.rows).slice(1).each(function(c){d[c]=this.id})});return d};b.fn.setSortName=function(f){return this.each(function(){var c=this;for(var d=0;d<c.p.colModel.length;d++){if(c.p.colModel[d].name===f||c.p.colModel[d].index===f){b("tr th:eq("+c.p.lastsort+") div img",c.grid.hDiv).remove();c.p.lastsort=d;c.p.sortname=f;break}}})};b.fn.setSelection=function(w,z,q){return this.each(function(){var g=this,m,l,n;z=z===false?false:true;if(w===false){l=q}else{n=b(g).getInd(g.rows,w);l=b(g.rows[n])}w=b(l).attr("id");if(!l.html()){return}if(g.p.selrow&&g.p.scrollrows===true){var t=b(g).getInd(g.rows,g.p.selrow);var r=b(g).getInd(g.rows,w);if(r>=0){if(r>t){u(r,'d')}else{u(r,'u')}}}if(!g.p.multiselect){if(b(l).attr("class")!=="subgrid"){if(g.p.selrow){b("tr#"+g.p.selrow.replace(".","\\."),g.grid.bDiv).removeClass("selected")}g.p.selrow=w;b(l).addClass("selected");if(g.p.onSelectRow&&z){g.p.onSelectRow(g.p.selrow,true)}}}else{g.p.selrow=w;var o=b.inArray(g.p.selrow,g.p.selarrrow);if(o===-1){if(b(l).attr("class")!=="subgrid"){b(l).addClass("selected")}m=true;b("#jqg_"+g.p.selrow.replace(".","\\."),g.rows).attr("checked",m);g.p.selarrrow.push(g.p.selrow);if(g.p.onSelectRow&&z){g.p.onSelectRow(g.p.selrow,m)}}else{if(b(l).attr("class")!=="subgrid"){b(l).removeClass("selected")}m=false;b("#jqg_"+g.p.selrow.replace(".","\\."),g.rows).attr("checked",m);g.p.selarrrow.splice(o,1);if(g.p.onSelectRow&&z){g.p.onSelectRow(g.p.selrow,m)}var p=g.p.selarrrow[0];g.p.selrow=(p==undefined)?null:p}}function u(c,d){var f=b(g.grid.bDiv)[0].clientHeight,h=b(g.grid.bDiv)[0].scrollTop,i=g.rows[c].offsetTop+g.rows[c].clientHeight,j=g.rows[c].offsetTop;if(d=='d'){if(i>=f){b(g.grid.bDiv)[0].scrollTop=h+i-j}}if(d=='u'){if(j<h){b(g.grid.bDiv)[0].scrollTop=h-i+j}}}})};b.fn.resetSelection=function(){return this.each(function(){var f=this,h;if(!f.p.multiselect){if(f.p.selrow){b("tr#"+f.p.selrow.replace(".","\\."),f.grid.bDiv).removeClass("selected");f.p.selrow=null}}else{b(f.p.selarrrow).each(function(c,d){h=b(f).getInd(f.rows,d);b(f.rows[h]).removeClass("selected");b("#jqg_"+d.replace(".","\\."),f.rows[h]).attr("checked",false)});b("#cb_jqg",f.grid.hDiv).attr("checked",false);f.p.selarrrow=[]}})};b.fn.getRowData=function(i){var j={};if(i){this.each(function(){var d=this,f,h;h=b(d).getInd(d.rows,i);if(!h){return j}b('td',d.rows[h]).each(function(c){f=d.p.colModel[c].name;if(f!=='cb'&&f!=='subgrid'){j[f]=b.htmlDecode(b(this).html())}})})}return j};b.fn.delRowData=function(f){var h=false,i,j;if(f){this.each(function(){var d=this;i=b(d).getInd(d.rows,f);if(!i){return false}else{b(d.rows[i]).remove();d.p.records--;d.updatepager();h=true;if(f==d.p.selrow){d.p.selrow=null}j=b.inArray(f,d.p.selarrrow);if(j!=-1){d.p.selarrrow.splice(j,1)}}if(i==1&&h&&(b.browser.opera||b.browser.safari)){b(d.rows[1]).each(function(c){b(this).css("width",d.grid.headers[c].width+"px");d.grid.cols[c]=this})}if(d.p.altRows===true&&h){b(d.rows).slice(1).each(function(c){if(c%2==1){b(this).addClass('alt')}else{b(this).removeClass('alt')}})}})}return h};b.fn.setRowData=function(j,g){var m,l=false;this.each(function(){var d=this,f,h,i;if(!d.grid){return false}if(g){h=b(d).getInd(d.rows,j);if(!h){return false}l=true;b(this.p.colModel).each(function(c){m=this.name;f=g[m];if(f!==undefined){if(d.p.treeGrid===true&&m==d.p.ExpandColumn){i=b("td:eq("+c+") > span:first",d.rows[h])}else{i=b("td:eq("+c+")",d.rows[h])}d.formatter(i,d.rows[h],f,c,'edit');l=true}})}});return l};b.fn.addRowData=function(f,h,i,j){if(!i){i="last"}var g=false,m,l,n,t=0,r=0,o,p;if(h){this.each(function(){var d=this;l=document.createElement("tr");l.id=f||d.p.records+1;b(l).addClass("jqgrow");if(d.p.multiselect){n=b('<td></td>');b(n[0],d.grid.bDiv).html("<input type='checkbox' id='jqg_"+f+"' class='cbox'/>");l.appendChild(n[0]);t=1}if(d.p.subGrid){try{b(d).addSubGrid(d.grid.bDiv,l,t)}catch(e){}r=1}for(p=t+r;p<this.p.colModel.length;p++){m=this.p.colModel[p].name;n=b('<td></td>');d.formatter(n,l,h[m],p,'add');d.formatCol(b(n[0],d.grid.bDiv),p);l.appendChild(n[0])}switch(i){case'last':b(d.rows[d.rows.length-1]).after(l);break;case'first':b(d.rows[0]).after(l);break;case'after':o=b(d).getInd(d.rows,j);o>=0?b(d.rows[o]).after(l):"";break;case'before':o=b(d).getInd(d.rows,j);o>0?b(d.rows[o-1]).after(l):"";break}d.p.records++;if(b.browser.safari||b.browser.opera){d.scrollLeft=d.scrollLeft;b("td",d.rows[1]).each(function(c){b(this).css("width",d.grid.headers[c].width+"px");d.grid.cols[c]=this})}if(d.p.altRows===true){if(i=="last"){if(d.rows.length%2==1){b(l).addClass('alt')}}else{b(d.rows).slice(1).each(function(c){if(c%2==1){b(this).addClass('alt')}else{b(this).removeClass('alt')}})}}try{d.p.afterInsertRow(l.id,h)}catch(e){}d.updatepager();g=true})}return g};b.fn.hideCol=function(g){return this.each(function(){var f=this,h=0,i=false,j;if(!f.grid){return}if(typeof g=='string'){g=[g]}b(this.p.colModel).each(function(d){if(b.inArray(this.name,g)!=-1&&!this.hidden){h=parseInt(b("tr th:eq("+d+")",f.grid.hDiv).css("width"),10);b("tr th:eq("+d+")",f.grid.hDiv).css({display:"none"});b(f.rows).each(function(c){b("td:eq("+d+")",f.rows[c]).css({display:"none"})});f.grid.cols[d].style.width=0;f.grid.headers[d].width=0;f.grid.width-=h;this.hidden=true;i=true}});if(i===true){j=Math.min(f.p._width,f.grid.width);b("table:first",f.grid.hDiv).width(j);b("table:first",f.grid.bDiv).width(j);b(f.grid.hDiv).width(j);b(f.grid.bDiv).width(j);if(f.p.pager&&b(f.p.pager).hasClass("scroll")){b(f.p.pager).width(j)}if(f.p.caption){b(f.grid.cDiv).width(j)}if(f.p.toolbar[0]){b(f.grid.uDiv).width(j)}f.grid.hDiv.scrollLeft=f.grid.bDiv.scrollLeft}})};b.fn.showCol=function(m){return this.each(function(){var f=this,h=0,i=false,j,g;if(!f.grid){return}if(typeof m=='string'){m=[m]}b(f.p.colModel).each(function(d){if(b.inArray(this.name,m)!=-1&&this.hidden){h=parseInt(b("tr th:eq("+d+")",f.grid.hDiv).css("width"),10);b("tr th:eq("+d+")",f.grid.hDiv).css("display","");b(f.rows).each(function(c){b("td:eq("+d+")",f.rows[c]).css("display","").width(h)});this.hidden=false;f.grid.cols[d].style.width=h;f.grid.headers[d].width=h;f.grid.width+=h;i=true}});if(i===true){j=Math.min(f.p._width,f.grid.width);g=(f.grid.width<=f.p._width)?"hidden":"auto";b("table:first",f.grid.hDiv).width(j);b("table:first",f.grid.bDiv).width(j);b(f.grid.hDiv).width(j);b(f.grid.bDiv).width(j).css("overflow-x",g);if(f.p.pager&&b(f.p.pager).hasClass("scroll")){b(f.p.pager).width(j)}if(f.p.caption){b(f.grid.cDiv).width(j)}if(f.p.toolbar[0]){b(f.grid.uDiv).width(j)}f.grid.hDiv.scrollLeft=f.grid.bDiv.scrollLeft}})};b.fn.setGridWidth=function(u,w){return this.each(function(){var g=this,m=0,l,n,t;if(!g.grid){return}if(typeof w!='boolean'){w=true}var r=p();if(w!==true){r[0]=Math.min(g.p._width,g.grid.width);r[2]=0}else{r[2]=r[1]}b.each(g.p.colModel,function(c,d){if(!this.hidden&&this.name!='cb'&&this.name!='subgrid'){n=w!==true?b("tr:first th:eq("+c+")",g.grid.hDiv).css("width"):this.width;l=Math.floor((o(u)-o(r[2]))/o(r[0])*o(n));m+=l;b("table thead tr:first th:eq("+c+")",g.grid.hDiv).css("width",l+"px");b("table:first tbody tr:first td:eq("+c+")",g.grid.bDiv).css("width",l+"px");g.grid.cols[c].style.width=l;g.grid.headers[c].width=l}if(this.name=='cb'||this.name=='subgrid'){m+=o(this.width)}});if(m+r[1]<=u||g.p.forceFit===true){t="hidden";tw=u}else{t="auto";tw=m+r[1]}b("table:first",g.grid.hDiv).width(tw);b("table:first",g.grid.bDiv).width(tw);b(g.grid.hDiv).width(u);b(g.grid.bDiv).width(u).css("overflow-x",t);if(g.p.pager&&b(g.p.pager).hasClass("scroll")){b(g.p.pager).width(u)}if(g.p.caption){b(g.grid.cDiv).width(u)}if(g.p.toolbar[0]){b(g.grid.uDiv).width(u)}g.p._width=u;g.grid.width=tw;if(b.browser.safari||b.browser.opera){b("table tbody tr:eq(1) td",g.grid.bDiv).each(function(c){b(this).css("width",g.grid.headers[c].width+"px");g.grid.cols[c]=this})}g.grid.hDiv.scrollLeft=g.grid.bDiv.scrollLeft;function o(c){c=parseInt(c,10);return isNaN(c)?0:c}function p(){var f=b("table tr:first th:eq(1)",g.grid.hDiv);var h=o(b(f).css("padding-left"))+o(b(f).css("padding-right"))+o(b(f).css("border-left-width"))+o(b(f).css("border-right-width"));var i=0,j=0;b.each(g.p.colModel,function(c,d){if(!this.hidden){i+=parseInt(this.width);j+=h}});return[i,j,0]}})};b.fn.setGridHeight=function(h){return this.each(function(){var c,d,f=this;if(!f.grid){return}if(f.p.forceFit===true){d='hidden'}else{d=b(f.grid.bDiv).css("overflow-x")}c=(isNaN(h)&&b.browser.mozilla&&(h.indexOf("%")!=-1||h=="auto"))?"hidden":"auto";b(f.grid.bDiv).css({height:h+(isNaN(h)?"":"px"),"overflow-y":c,"overflow-x":d});f.p.height=h})};b.fn.setCaption=function(c){return this.each(function(){this.p.caption=c;b("table:first th",this.grid.cDiv).html(c);b(this.grid.cDiv).show()})};b.fn.setLabel=function(i,j,g,m){return this.each(function(){var d=this,f=-1;if(!d.grid){return}if(isNaN(i)){b(d.p.colModel).each(function(c){if(this.name==i){f=c;return false}})}else{f=parseInt(i,10)}if(f>=0){var h=b("table:first th:eq("+f+")",d.grid.hDiv);if(j){b("div",h).html(j)}if(g){if(typeof g=='string'){b(h).addClass(g)}else{b(h).css(g)}}if(typeof m=='object'){b(h).attr(m)}}})};b.fn.setCell=function(j,g,m,l,n){return this.each(function(){var d=this,f=-1;if(!d.grid){return}if(isNaN(g)){b(d.p.colModel).each(function(c){if(this.name==g){f=c;return false}})}else{f=parseInt(g,10)}if(f>=0){var h=b(d).getInd(d.rows,j);if(h){var i=b("td:eq("+f+")",d.rows[h]);if(m!=""){d.formatter(i,d.rows[h],m,f,'edit')}if(l){if(typeof l=='string'){b(i).addClass(l)}else{b(i).css(l)}}if(typeof n=='object'){b(i).attr(n)}}}})};b.fn.getCell=function(i,j){var g=false;this.each(function(){var d=this,f=-1;if(!d.grid){return}if(isNaN(j)){b(d.p.colModel).each(function(c){if(this.name==j){f=c;return false}})}else{f=parseInt(j,10)}if(i&&f>=0){var h=b(d).getInd(d.rows,i);if(h){g=b.htmlDecode(b("td:eq("+f+")",d.rows[h]).html())}}});return g};b.fn.clearGridData=function(){return this.each(function(){var c=this;if(!c.grid){return}b("tbody tr:gt(0)",c.grid.bDiv).remove();c.p.selrow=null;c.p.selarrrow=[];c.p.savedRow=[];c.p.records='0';c.p.page='0';c.p.lastpage='0';c.updatepager()})};b.fn.getInd=function(d,f,h){var i=false;b(d).each(function(c){if(this.id==f){i=h===true?this:c;return false}});return i};b.htmlDecode=function(c){if(c=='&nbsp;'||c=='&#160;'){c=""}return!c?c:String(c).replace(/&amp;/g,"&").replace(/&gt;/g,">").replace(/&lt;/g,"<").replace(/&quot;/g,'"')};return this.each(function(){if(this.grid){return}this.p=x;if(this.p.colNames.length===0){for(var q=0;q<this.p.colModel.length;q++){this.p.colNames[q]=this.p.colModel[q].label||this.p.colModel[q].name}}if(this.p.colNames.length!==this.p.colModel.length){alert(b.jgrid.errors.model);return}if(this.p.imgpath!==""){this.p.imgpath+="/"}b("<div class='loadingui' id=lui_"+this.id+"><div class='msgbox'>"+this.p.loadtext+"</div></div>").insertBefore(this);b(this).attr({cellSpacing:"0",cellPadding:"0",border:"0"});var a=this,ba=b.isFunction(this.p.beforeSelectRow)?this.p.beforeSelectRow:false,bD=b.isFunction(this.p.onSelectRow)?this.p.onSelectRow:false,bo=b.isFunction(this.p.ondblClickRow)?this.p.ondblClickRow:false,bb=b.isFunction(this.p.onSortCol)?this.p.onSortCol:false,B=b.isFunction(this.p.loadComplete)?this.p.loadComplete:false,J=b.isFunction(this.p.loadError)?this.p.loadError:false,K=b.isFunction(this.p.loadBeforeSend)?this.p.loadBeforeSend:false,bp=b.isFunction(this.p.onRightClickRow)?this.p.onRightClickRow:false,bc=b.isFunction(this.p.afterInsertRow)?this.p.afterInsertRow:false,bd=b.isFunction(this.p.onHeaderClick)?this.p.onHeaderClick:false,bq=b.isFunction(this.p.beforeRequest)?this.p.beforeRequest:false,be=b.isFunction(this.p.onCellSelect)?this.p.onCellSelect:false,br=["shiftKey","altKey","ctrlKey"];if(b.inArray(a.p.multikey,br)==-1){a.p.multikey=false}var y=function(c,d){c=parseInt(c,10);if(isNaN(c)){return(d)?d:0}else{return c}};var T=function(c,d){var f=a.p.colModel[d].align;if(f){b(c).css("text-align",f)}if(a.p.colModel[d].hidden){b(c).css("display","none")}};var U=function(d,f){b("tbody tr:eq("+f+") td",d).each(function(c){b(this).css("width",k.headers[c].width+"px");k.cols[c]=this})};var L=function(c,d,f,h){var i;i=document.createElement("td");bf(b(i,c),d,f,h,'add');d.appendChild(i);T(b(i,c),h)};var bf=function(c,d,f,h,i){var j=a.p.colModel[h];if(j.formatter){var g={rowId:d.id,colModel:j,rowData:d};if(b.isFunction(j.formatter)){j.formatter(c,f,g,i)}else if(b.fmatter){b(c).fmatter(j.formatter,f,g,i)}else{b(c).html(f||'&#160;')}}else{b(c).html(f||'&#160;')}c[0].title=c[0].textContent||c[0].innerText};var bg=function(c,d){var f,h;h=document.createElement("td");f="jqg_"+d.id;b(h,c).html("<input type='checkbox' id='"+f+"' class='cbox'/>");T(b(h,c),0);d.appendChild(h)};var bh=function(c){var d,f=[],h=0,i;for(i=0;i<a.p.colModel.length;i++){d=a.p.colModel[i];if(d.name!=='cb'&&d.name!=='subgrid'){f[h]=(c=="xml")?d.xmlmap||d.name:d.jsonmap||d.name;h++}}return f};var M=function M(h,i,j){if(h){var g=a.p.treeANode||0;j=j||0;if(g===0&&j===0){b("tbody tr:gt(0)",i).remove()}}else{return}var m,l,n=0,t=0,r,o,p,u=[],w=[],z=(a.p.altRows===true)?'alt':'';if(!a.p.xmlReader.repeatitems){u=bh("xml")}if(a.p.keyIndex===false){o=a.p.xmlReader.id;if(o.indexOf("[")===-1){p=function(c,d){return b(o,c).text()||d}}else{p=function(c,d){return c.getAttribute(o.replace(/[\[\]]/g,""))||d}}}else{p=function(c){return(u.length-1>=a.p.keyIndex)?b(u[a.p.keyIndex],c).text():b(a.p.xmlReader.cell+":eq("+a.p.keyIndex+")",c).text()}}b(a.p.xmlReader.page,h).each(function(){a.p.page=this.textContent||this.text});b(a.p.xmlReader.total,h).each(function(){a.p.lastpage=this.textContent||this.text});b(a.p.xmlReader.records,h).each(function(){a.p.records=this.textContent||this.text});b(a.p.xmlReader.userdata,h).each(function(){a.p.userData[this.getAttribute("name")]=this.textContent||this.text});b(a.p.xmlReader.root+" "+a.p.xmlReader.row,h).each(function(d){l=document.createElement("tr");l.id=p(this,d+1);if(a.p.multiselect){bg(i,l);n=1}if(a.p.subGrid){try{b(a).addSubGrid(i,l,n,this)}catch(e){}t=1}if(a.p.xmlReader.repeatitems===true){b(a.p.xmlReader.cell,this).each(function(c){m=this.textContent||this.text;L(i,l,m,c+n+t);w[a.p.colModel[c+n+t].name]=m})}else{for(var f=0;f<u.length;f++){m=b(u[f],this).text();L(i,l,m,f+n+t);w[a.p.colModel[f+n+t].name]=m}}if(d%2==1){l.className=z}b(l).addClass("jqgrow");if(a.p.treeGrid===true){try{b(a).setTreeNode(w,l)}catch(e){}}b(a.rows[d+g+j]).after(l);if(bc){a.p.afterInsertRow(l.id,w,this)}w=[]});if(N||O){U(i,1)}if(!a.p.treeGrid&&!a.p.scroll){a.grid.bDiv.scrollTop=0}F();V()};var W=function(c,d,f){if(c){var h=a.p.treeANode||0;f=f||0;if(h===0&&f===0){b("tbody tr:gt(0)",d).remove()}}else{return}var i,j,g,m,l=[],n,t=0,r=0,o,p,u=[],w=(a.p.altRows===true)?'alt':'';a.p.page=c[a.p.jsonReader.page];a.p.lastpage=c[a.p.jsonReader.total];a.p.records=c[a.p.jsonReader.records];a.p.userData=c[a.p.jsonReader.userdata]||{};if(!a.p.jsonReader.repeatitems){l=bh("json")}if(a.p.keyIndex===false){p=a.p.jsonReader.id;if(l.length>0&&!isNaN(p)){p=l[p]}}else{p=l.length>0?l[a.p.keyIndex]:a.p.keyIndex}o=c[a.p.jsonReader.root];if(o){for(j=0;j<o.length;j++){n=o[j];m=document.createElement("tr");m.id=n[p]||"";if(m.id===""){if(l.length===0){if(a.p.jsonReader.cell){var z=n[a.p.jsonReader.cell];m.id=z[p]||j+1;z=null}else{m.id=j+1}}else{m.id=j+1}}if(a.p.multiselect){bg(d,m);t=1}if(a.p.subGrid){try{b(a).addSubGrid(d,m,t,o[j])}catch(e){}r=1}if(a.p.jsonReader.repeatitems===true){if(a.p.jsonReader.cell){n=n[a.p.jsonReader.cell]}for(g=0;g<n.length;g++){L(d,m,n[g],g+t+r);u[a.p.colModel[g+t+r].name]=n[g]}}else{for(g=0;g<l.length;g++){i=n[l[g]];if(i===undefined){try{i=eval("cur."+l[g])}catch(e){}}L(d,m,i,g+t+r);u[a.p.colModel[g+t+r].name]=n[l[g]]}}if(j%2==1){m.className=w}b(m).addClass("jqgrow");if(a.p.treeGrid===true){try{b(a).setTreeNode(u,m)}catch(e){}}b(a.rows[j+h+f]).after(m);if(bc){a.p.afterInsertRow(m.id,u,o[j])}u=[]}}if(N||O){U(d,1)}if(!a.p.treeGrid&&!a.p.scroll){a.grid.bDiv.scrollTop=0}F();V()};var V=function(){if(a.p.pager){var c,d,f=a.p.imgpath;if(a.p.loadonce){c=d=1;a.p.lastpage=a.page=1;b(".selbox",a.p.pager).attr("disabled",true)}else{c=y(a.p.page);d=y(a.p.lastpage);b(".selbox",a.p.pager).attr("disabled",false)}if(a.p.pginput===true){b('input.selbox',a.p.pager).val(a.p.page)}if(a.p.viewrecords){if(a.p.pgtext){b('#sp_1',a.p.pager).html(a.p.pgtext+"&#160;"+a.p.lastpage)}b('#sp_2',a.p.pager).html(a.p.records+"&#160;"+a.p.recordtext+"&#160;")}if(a.p.pgbuttons===true){if(c<=0){c=d=1}if(c==1){b("#first",a.p.pager).attr({src:f+"off-"+a.p.firstimg,disabled:true})}else{b("#first",a.p.pager).attr({src:f+a.p.firstimg,disabled:false})}if(c==1){b("#prev",a.p.pager).attr({src:f+"off-"+a.p.previmg,disabled:true})}else{b("#prev",a.p.pager).attr({src:f+a.p.previmg,disabled:false})}if(c==d){b("#next",a.p.pager).attr({src:f+"off-"+a.p.nextimg,disabled:true})}else{b("#next",a.p.pager).attr({src:f+a.p.nextimg,disabled:false})}if(c==d){b("#last",a.p.pager).attr({src:f+"off-"+a.p.lastimg,disabled:true})}else{b("#last",a.p.pager).attr({src:f+a.p.lastimg,disabled:false})}}}if(b.isFunction(a.p.gridComplete)){a.p.gridComplete()}};var C=function(){if(!k.hDiv.loading){bs();var h,i={nd:(new Date().getTime()),_search:a.p.search};i[a.p.prmNames.rows]=a.p.rowNum;i[a.p.prmNames.page]=a.p.page;i[a.p.prmNames.sort]=a.p.sortname;i[a.p.prmNames.order]=a.p.sortorder;h=b.extend(a.p.postData,i);if(a.p.search===true){h=b.extend(h,a.p.searchdata)}if(b.isFunction(a.p.datatype)){a.p.datatype(h);F()}var j=a.p.scroll===false?0:a.rows.length-1;switch(a.p.datatype){case"json":b.ajax({url:a.p.url,type:a.p.mtype,dataType:"json",data:h,complete:function(c,d){if(d=="success"){W(eval("("+c.responseText+")"),a.grid.bDiv,j);c=null;if(B){B()}}},error:function(c,d,f){if(J){J(c,d,f)}F()},beforeSend:function(c){if(K){K(c)}}});if(a.p.loadonce||a.p.treeGrid){a.p.datatype="local"}break;case"xml":b.ajax({url:a.p.url,type:a.p.mtype,dataType:"xml",data:h,complete:function(c,d){if(d=="success"){M(c.responseXML,a.grid.bDiv,j);c=null;if(B){B()}}},error:function(c,d,f){if(J){J(c,d,f)}F()},beforeSend:function(c){if(K){K(c)}}});if(a.p.loadonce||a.p.treeGrid){a.p.datatype="local"}break;case"xmlstring":M(bt(a.p.datastr),a.grid.bDiv);a.p.datastr=null;a.p.datatype="local";if(B){B()}break;case"jsonstring":if(typeof a.p.datastr=='string'){a.p.datastr=eval("("+a.p.datastr+")")}W(a.p.datastr,a.grid.bDiv);a.p.datastr=null;a.p.datatype="local";if(B){B()}break;case"local":case"clientSide":a.p.datatype="local";bu();break}}};var bs=function(){if(bq){a.p.beforeRequest()}k.hDiv.loading=true;switch(a.p.loadui){case"disable":break;case"enable":b("div.loading",k.hDiv).fadeIn("fast");break;case"block":b("#lui_"+a.id).width(b(k.bDiv).width()).height(y(b(k.bDiv).height())+y(a.p._height)).fadeIn("fast");break}};var F=function(){k.hDiv.loading=false;switch(a.p.loadui){case"disable":break;case"enable":b("div.loading",k.hDiv).fadeOut("fast");break;case"block":b("#lui_"+a.id).fadeOut("fast");break}};var bt=function(c){var d;if(typeof c!=='string')return c;try{var f=new DOMParser();d=f.parseFromString(c,"text/xml")}catch(e){d=new ActiveXObject("Microsoft.XMLDOM");d.async=false;d["loadXML"](c)}return(d&&d.documentElement&&d.documentElement.tagName!='parsererror')?d:null};var bu=function(){var f=/[\$,%]/g;var h=[],i=0,j,g,m,l=(a.p.sortorder=="asc")?1:-1;b.each(a.p.colModel,function(c,d){if(this.index==a.p.sortname||this.name==a.p.sortname){i=a.p.lastsort=c;j=this.sorttype;return false}});if(j=='float'||j=='number'||j=='currency'){m=function(c){var d=parseFloat(c.replace(f,''));return isNaN(d)?0:d}}else if(j=='int'||j=='integer'){m=function(c){return y(c.replace(f,''))}}else if(j=='date'){m=function(c){var d=a.p.colModel[i].datefmt||"Y-m-d";return bv(d,c).getTime()}}else{m=function(c){return b.trim(c.toUpperCase())}}b.each(a.rows,function(c,d){if(c>0){try{g=b.unformat(b(d).children('td').eq(i),{colModel:a.p.colModel[i]},i,true)}catch(_){g=b(d).children('td').eq(i).text()}d.sortKey=m(g);h[c-1]=this}});if(a.p.treeGrid){b(a).SortTree(l)}else{h.sort(function(c,d){if(c.sortKey<d.sortKey){return-l}if(c.sortKey>d.sortKey){return l}return 0});b.each(h,function(c,d){b('tbody',a.grid.bDiv).append(d);d.sortKey=null})}if(N||O){U(a.grid.bDiv,1)}if(a.p.multiselect){b("tbody tr:gt(0)",a.grid.bDiv).removeClass("selected");b("[id^=jqg_]",a.rows).attr("checked",false);b("#cb_jqg",a.grid.hDiv).attr("checked",false);a.p.selarrrow=[]}if(a.p.altRows===true){b("tbody tr:gt(0)",a.grid.bDiv).removeClass("alt");b("tbody tr:odd",a.grid.bDiv).addClass("alt")}a.grid.bDiv.scrollTop=0;F()};var bv=function(c,d){var f={m:1,d:1,y:1970,h:0,i:0,s:0};c=c.toLowerCase();d=d.split(/[\\\/:_;.\s-]/);c=c.split(/[\\\/:_;.\s-]/);for(var h=0;h<c.length;h++){f[c[h]]=y(d[h],f[c[h]])}f.m=parseInt(f.m,10)-1;var i=f.y;if(i>=70&&i<=99){f.y=1900+f.y}else if(i>=0&&i<=69){f.y=2000+f.y}return new Date(f.y,f.m,f.d,f.h,f.i,f.s,0)};var bw=function(){var l="<img class='pgbuttons' src='"+a.p.imgpath+"spacer.gif'",n=(a.p.pginput===true)?"<input class='selbox' type='text' size='3' maxlength='5' value='0'/>":"",t="",r="",o;if(a.p.viewrecords===true){n+="<span id='sp_1'></span>&#160;"}if(a.p.pgbuttons===true){t=l+" id='first'/>&#160;&#160;"+l+" id='prev'/>&#160;";r=l+" id='next' />&#160;&#160;"+l+" id='last'/>"}b(a.p.pager).append(t+n+r);if(a.p.rowList.length>0){o="<SELECT class='selbox'>";for(var p=0;p<a.p.rowList.length;p++){o+="<OPTION value="+a.p.rowList[p]+((a.p.rowNum==a.p.rowList[p])?' selected':'')+">"+a.p.rowList[p]}o+="</SELECT>";b(a.p.pager).append("&#160;"+o+"&#160;<span id='sp_2'></span>");b(a.p.pager).find("select").bind('change',function(){a.p.rowNum=(this.value>0)?this.value:a.p.rowNum;if(typeof a.p.onPaging=='function'){a.p.onPaging('records')}C();a.p.selrow=null})}else{b(a.p.pager).append("&#160;<span id='sp_2'></span>")}if(a.p.pgbuttons===true){b(".pgbuttons",a.p.pager).mouseover(function(c){if(b(this).attr('disabled')=='true'){this.style.cursor='auto'}else{this.style.cursor="pointer"}return false}).mouseout(function(c){this.style.cursor="default";return false});b("#first, #prev, #next, #last",a.p.pager).click(function(c){var d=y(a.p.page),f=y(a.p.lastpage),h=false,i=true,j=true,g=true,m=true;if(f===0||f===1){i=false;j=false;g=false;m=false}else if(f>1&&d>=1){if(d===1){i=false;j=false}else if(d>1&&d<f){}else if(d===f){g=false;m=false}}else if(f>1&&d===0){g=false;m=false;d=f-1}if(this.id==='first'&&i){a.p.page=1;h=true}if(this.id==='prev'&&j){a.p.page=(d-1);h=true}if(this.id==='next'&&g){a.p.page=(d+1);h=true}if(this.id==='last'&&m){a.p.page=f;h=true}if(h){if(typeof a.p.onPaging=='function'){a.p.onPaging(this.id)}C();a.p.selrow=null;if(a.p.multiselect){a.p.selarrrow=[];b('#cb_jqg',a.grid.hDiv).attr("checked",false)}a.p.savedRow=[]}c.stopPropagation();return false})}if(a.p.pginput===true){b('input.selbox',a.p.pager).keypress(function(c){var d=c.charCode?c.charCode:c.keyCode?c.keyCode:0;if(d==13){a.p.page=(b(this).val()>0)?b(this).val():a.p.page;if(typeof a.p.onPaging=='function'){a.p.onPaging('user')}C();a.p.selrow=null;return false}return this})}};var bi=function(c,d,f){var h,i,j,g,m;if(a.p.savedRow.length>0){return}if(!f){if(a.p.lastsort===d){if(a.p.sortorder==='asc'){a.p.sortorder='desc'}else if(a.p.sortorder==='desc'){a.p.sortorder='asc'}}else{a.p.sortorder='asc'}a.p.page=1}h=(a.p.sortorder==='asc')?a.p.sortascimg:a.p.sortdescimg;h="<img src='"+a.p.imgpath+h+"'>";var l=b("thead:first",k.hDiv).get(0);g=a.p.colModel[a.p.lastsort].name.replace('.',"\\.");b("tr th div#jqgh_"+g+" img",l).remove();b("tr th div#jqgh_"+g,l).parent().removeClass(a.p.sortclass);m=c.replace('.',"\\.");b("tr th div#"+m,l).append(h).parent().addClass(a.p.sortclass);a.p.lastsort=d;c=c.substring(5);a.p.sortname=a.p.colModel[d].index||c;i=a.p.sortorder;if(bb){bb(c,d,i)}if(a.p.datatype=="local"){if(a.p.deselectAfterSort){b(a).resetSelection()}}else{a.p.selrow=null;if(a.p.multiselect){b("#cb_jqg",a.grid.hDiv).attr("checked",false)}a.p.selarrrow=[];a.p.savedRow=[]}j=a.p.scroll;if(a.p.scroll===true){a.p.scroll=false}C();if(a.p.sortname!=c&&d){a.p.lastsort=d}setTimeout(function(){a.p.scroll=j},500)};var bx=function(){var c=0;for(var d=0;d<a.p.colModel.length;d++){if(!a.p.colModel[d].hidden){c+=y(a.p.colModel[d].width)}}var f=a.p.width?a.p.width:c;for(d=0;d<a.p.colModel.length;d++){if(!a.p.shrinkToFit){a.p.colModel[d].owidth=a.p.colModel[d].width}a.p.colModel[d].width=Math.round(f/c*a.p.colModel[d].width)}};var by=function(c){var d=c,f=c,h;for(h=c+1;h<a.p.colModel.length;h++){if(a.p.colModel[h].hidden!==true){f=h;break}}return f-d};this.p.id=this.id;if(this.p.treeGrid===true){this.p.subGrid=false;this.p.altRows=false;this.p.pgbuttons=false;this.p.pginput=false;this.p.multiselect=false;this.p.rowList=[];try{b(this).setTreeGrid();this.p.treedatatype=this.p.datatype;b.each(this.p.treeReader,function(c,d){if(d){a.p.colNames.push(d);a.p.colModel.push({name:d,width:1,hidden:true,sortable:false,resizable:false,hidedlg:true,editable:true,search:false})}})}catch(_){}}a.p.keyIndex=false;for(var q=0;q<a.p.colModel.length;q++){if(a.p.colModel[q].key===true){a.p.keyIndex=q;break}}if(this.p.subGrid){this.p.colNames.unshift("");this.p.colModel.unshift({name:'subgrid',width:25,sortable:false,resizable:false,hidedlg:true,search:false})}if(this.p.multiselect){this.p.colNames.unshift("<input id='cb_jqg' class='cbox' type='checkbox'/>");this.p.colModel.unshift({name:'cb',width:27,sortable:false,resizable:false,hidedlg:true,search:false})}var bz={root:"rows",row:"row",page:"rows>page",total:"rows>total",records:"rows>records",repeatitems:true,cell:"cell",id:"[id]",userdata:"userdata",subgrid:{root:"rows",row:"row",repeatitems:true,cell:"cell"}};var bA={root:"rows",page:"page",total:"total",records:"records",repeatitems:true,cell:"cell",id:"id",userdata:"userdata",subgrid:{root:"rows",repeatitems:true,cell:"cell"}};if(a.p.scroll===true){a.p.pgbuttons=false;a.p.pginput=false;a.p.pgtext=false;a.p.rowList=[]}a.p.xmlReader=b.extend(bz,a.p.xmlReader);a.p.jsonReader=b.extend(bA,a.p.jsonReader);b.each(a.p.colModel,function(c){this.width=y(this.width,150)});if(a.p.width){bx()}var G=document.createElement("thead");var A=document.createElement("tr");G.appendChild(A);var q=0,P,X,H;if(a.p.shrinkToFit===true&&a.p.forceFit===true){for(q=a.p.colModel.length-1;q>=0;q--){if(!a.p.colModel[q].hidden){a.p.colModel[q].resizable=false;break}}}for(q=0;q<this.p.colNames.length;q++){P=document.createElement("th");X=a.p.colModel[q].name;H=document.createElement("div");b(H).html(a.p.colNames[q]+"&#160;");if(X==a.p.sortname){var Y=(a.p.sortorder==='asc')?a.p.sortascimg:a.p.sortdescimg;Y="<img src='"+a.p.imgpath+Y+"'>";b(H).append(Y);a.p.lastsort=q;b(P).addClass(a.p.sortclass)}H.id="jqgh_"+X;P.appendChild(H);A.appendChild(P)}if(this.p.multiselect){var bj=true;if(typeof a.p.onSelectAll!=='function'){bj=false}b('#cb_jqg',A).click(function(){var d;if(this.checked){b("[id^=jqg_]",a.rows).attr("checked",true);b(a.rows).slice(1).each(function(c){if(!b(this).hasClass("subgrid")){b(this).addClass("selected");a.p.selarrrow[c]=a.p.selrow=this.id}});d=true}else{b("[id^=jqg_]",a.rows).attr("checked",false);b(a.rows).slice(1).each(function(c){if(!b(this).hasClass("subgrid")){b(this).removeClass("selected")}});a.p.selarrrow=[];a.p.selrow=null;d=false}if(bj){a.p.onSelectAll(a.p.selarrrow,d)}})}this.appendChild(G);G=b("thead:first",a).get(0);var D,I,Q;b("tr:first th",G).each(function(d){D=a.p.colModel[d].width;if(typeof a.p.colModel[d].resizable==='undefined'){a.p.colModel[d].resizable=true}I=document.createElement("span");b(I).html("&#160;");if(a.p.colModel[d].resizable){b(this).addClass(a.p.resizeclass);b(I).mousedown(function(c){if(a.p.forceFit===true){a.p.nv=by(d)}k.dragStart(d,c.clientX);c.preventDefault();return false})}else{I=""}b(this).css("width",D+"px").prepend(I);if(a.p.colModel[d].hidden){b(this).css("display","none")}k.headers[d]={width:D,el:this};Q=a.p.colModel[d].sortable;if(typeof Q!=='boolean'){Q=true}if(Q){b("div",this).css("cursor","pointer").click(function(){bi(this.id,d);return false})}});var bB=b.browser.msie?true:false,bk=b.browser.mozilla?true:false,O=b.browser.opera?true:false,N=b.browser.safari?true:false,v,s,bl=0,bm=0,bn=document.createElement("tbody");A=document.createElement("tr");A.id="_empty";bn.appendChild(A);for(q=0;q<a.p.colNames.length;q++){v=document.createElement("td");A.appendChild(v)}this.appendChild(bn);b("tbody tr:first td",a).each(function(c){D=a.p.colModel[c].width;b(this).css({width:D+"px",height:"0px"});D+=y(b(this).css("padding-left"))+y(b(this).css("padding-right"))+y(b(this).css("border-left-width"))+y(b(this).css("border-right-width"));if(a.p.colModel[c].hidden===true){b(this).css("display","none");bm+=D}k.cols[c]=this;bl+=D});if(bk){b(A).css({visibility:"collapse"})}else if(N||O){b(A).css({display:"none"})}k.width=y(bl)-y(bm);a.p._width=k.width;k.hTable=document.createElement("table");b(k.hTable).append(G).css({width:k.width+"px"}).attr({cellSpacing:"0",cellPadding:"0",border:"0"}).addClass("scroll grid_htable");k.hDiv=document.createElement("div");var E=(a.p.caption&&a.p.hiddengrid===true)?true:false;b(k.hDiv).css({width:k.width+"px",overflow:"hidden"}).prepend('<div class="loading">'+a.p.loadtext+'</div>').addClass("grid_hdiv").append(k.hTable).bind("selectstart",function(){return false});if(E){b(k.hDiv).hide();a.p.gridstate='hidden'}if(a.p.pager){if(typeof a.p.pager=="string"){if(a.p.pager.substr(0,1)!="#")a.p.pager="#"+a.p.pager}if(b(a.p.pager).hasClass("scroll")){b(a.p.pager).css({width:k.width+"px",overflow:"hidden"}).show();a.p._height=parseInt(b(a.p.pager).height(),10);if(E){b(a.p.pager).hide()}}bw()}if(a.p.cellEdit===false){b(a).mouseover(function(c){v=(c.target||c.srcElement);s=b(v,a.rows).parents("tr:first");if(b(s).hasClass("jqgrow")){b(s).addClass("over")}return false}).mouseout(function(c){v=(c.target||c.srcElement);s=b(v,a.rows).parents("tr:first");b(s).removeClass("over");return false})}var R,S;b(a).before(k.hDiv).css("width",k.width+"px").click(function(c){v=(c.target||c.srcElement);if(v.href){return true}var d=b(v).hasClass("cbox");s=b(v,a.rows).parent("tr");if(b(s).length===0){s=b(v,a.rows).parents("tr:first");v=b(v).parents("td:first")[0]}var f=true;if(ba){f=ba(s.attr("id"))}if(f===true){if(a.p.cellEdit===true){if(a.p.multiselect&&d){b(a).setSelection(false,true,s)}else{R=s[0].rowIndex;S=v.cellIndex;try{b(a).editCell(R,S,true,true)}catch(c){}}}else if(!a.p.multikey){if(a.p.multiselect&&a.p.multiboxonly){if(d){b(a).setSelection(false,true,s)}}else{b(a).setSelection(false,true,s)}}else{if(c[a.p.multikey]){b(a).setSelection(false,true,s)}else if(a.p.multiselect&&d){d=b("[id^=jqg_]",s).attr("checked");b("[id^=jqg_]",s).attr("checked",!d)}}if(be){R=s[0].id;S=v.cellIndex;be(R,S,b(v).html())}}c.stopPropagation()}).bind('reloadGrid',function(c){if(a.p.treeGrid===true){a.p.datatype=a.p.treedatatype}if(a.p.datatype=="local"){b(a).resetSelection()}else if(!a.p.treeGrid){a.p.selrow=null;if(a.p.multiselect){a.p.selarrrow=[];b('#cb_jqg',a.grid.hDiv).attr("checked",false)}if(a.p.cellEdit){a.p.savedRow=[]}}C()});if(bo){b(this).dblclick(function(c){v=(c.target||c.srcElement);s=b(v,a.rows).parent("tr");if(b(s).length===0){s=b(v,a.rows).parents("tr:first")}a.p.ondblClickRow(b(s).attr("id"));return false})}if(bp){b(this).bind('contextmenu',function(c){v=(c.target||c.srcElement);s=b(v,a).parents("tr:first");if(b(s).length===0){s=b(v,a.rows).parents("tr:first")}if(!a.p.multiselect){b(a).setSelection(false,true,s)}a.p.onRightClickRow(b(s).attr("id"));return false})}k.bDiv=document.createElement("div");var Z=(isNaN(a.p.height)&&bk&&(a.p.height.indexOf("%")!=-1||a.p.height=="auto"))?"hidden":"auto";b(k.bDiv).addClass("grid_bdiv").scroll(function(c){k.scrollGrid()}).css({height:a.p.height+(isNaN(a.p.height)?"":"px"),padding:"0px",margin:"0px",overflow:Z,width:(k.width)+"px"}).css("overflow-x","hidden").append(this);b("table:first",k.bDiv).css({width:k.width+"px"});if(bB){if(b("tbody",this).size()===2){b("tbody:first",this).remove()}if(a.p.multikey){b(k.bDiv).bind("selectstart",function(){return false})}if(a.p.treeGrid){b(k.bDiv).css("position","relative")}}else{if(a.p.multikey){b(k.bDiv).bind("mousedown",function(){return false})}}if(E){b(k.bDiv).hide()}k.cDiv=document.createElement("div");b(k.cDiv).append("<table class='Header' cellspacing='0' cellpadding='0' border='0'><tr><td class='HeaderLeft'><img src='"+a.p.imgpath+"spacer.gif' border='0' /></td><th>"+a.p.caption+"</th>"+((a.p.hidegrid===true)?"<td class='HeaderButton'><img src='"+a.p.imgpath+"up.gif' border='0'/></td>":"")+"<td class='HeaderRight'><img src='"+a.p.imgpath+"spacer.gif' border='0' /></td></tr></table>").addClass("GridHeader").width(k.width);b(k.cDiv).insertBefore(k.hDiv);if(a.p.toolbar[0]){k.uDiv=document.createElement("div");if(a.p.toolbar[1]=="top"){b(k.uDiv).insertBefore(k.hDiv)}else{b(k.uDiv).insertAfter(k.hDiv)}b(k.uDiv).width(k.width).addClass("userdata").attr("id","t_"+this.id);a.p._height+=parseInt(b(k.uDiv).height(),10);if(E){b(k.uDiv).hide()}}if(a.p.caption){a.p._height+=parseInt(b(k.cDiv,a).height(),10);var bC=a.p.datatype;if(a.p.hidegrid===true){b(".HeaderButton",k.cDiv).toggle(function(){if(a.p.pager){b(a.p.pager).slideUp()}if(a.p.toolbar[0]){b(k.uDiv,a).slideUp()}b(k.bDiv).hide();b(k.hDiv).slideUp();b("img",this).attr("src",a.p.imgpath+"down.gif");a.p.gridstate='hidden';if(bd){if(!E){a.p.onHeaderClick(a.p.gridstate)}}},function(){b(k.hDiv).slideDown();b(k.bDiv).show();if(a.p.pager){b(a.p.pager).slideDown()}if(a.p.toolbar[0]){b(k.uDiv).slideDown()}b("img",this).attr("src",a.p.imgpath+"up.gif");if(E){a.p.datatype=bC;C();E=false}a.p.gridstate='visible';if(bd){a.p.onHeaderClick(a.p.gridstate)}});if(E){b(".HeaderButton",k.cDiv).trigger("click");a.p.datatype="local"}}}else{b(k.cDiv).hide()}a.p._height+=parseInt(b(k.hDiv,a).height(),10);b(k.hDiv).mousemove(function(c){k.dragMove(c.clientX);return false}).after(k.bDiv);b(document).mouseup(function(c){if(k.resizing){k.dragEnd();if(k.newWidth&&a.p.forceFit===false){var d=(k.width<=a.p._width)?k.width:a.p._width;var f=(k.width<=a.p._width)?"hidden":"auto";if(a.p.pager&&b(a.p.pager).hasClass("scroll")){b(a.p.pager).width(d)}if(a.p.caption){b(k.cDiv).width(d)}if(a.p.toolbar[0]){b(k.uDiv).width(d)}b(k.bDiv).width(d).css("overflow-x",f);b(k.hDiv).width(d)}}return false});a.formatCol=function(c,d){T(c,d)};a.sortData=function(c,d,f){bi(c,d,f)};a.updatepager=function(){V()};a.formatter=function(c,d,f,h,i){bf(c,d,f,h,i)};b.extend(k,{populate:function(){C()}});this.grid=k;a.addXmlData=function(c){M(c,a.grid.bDiv)};a.addJSONData=function(c){W(c,a.grid.bDiv)};C();if(!a.p.shrinkToFit){a.p.forceFit=false;b("tr:first th",G).each(function(c){var d=a.p.colModel[c].owidth;var f=d-a.p.colModel[c].width;if(f>0&&!a.p.colModel[c].hidden){k.headers[c].width=d;b(this).add(k.cols[c]).width(d);b('table:first',k.bDiv).add(k.hTable).width(a.grid.width);a.grid.width+=f;k.hDiv.scrollLeft=k.bDiv.scrollLeft}});Z=(k.width<=a.p._width)?"hidden":"auto";b(k.bDiv).css({"overflow-x":Z})}b(window).unload(function(){b(this).unbind("*");this.grid=null;this.p=null})})}})(jQuery);