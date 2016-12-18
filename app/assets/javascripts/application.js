// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

//= require jquery
//= require jquery_ujs
//= require moment
//= require bootstrap.min
//= require jquery.form
//= require jquery.validate
//= require jquery.nicescroll.min
//= require hogan-2.0.0
//= require bootstrap-formhelpers-phone
//= require typeahead
//= require bootstrap-datetimepicker
//= require date.format
//= require jquery.dataTables.min
//= require DT_bootstrap 
//= require jquery.tablesorter.min
//= require fullcalendar.min
//= require bootstrap-editable.min
//= require bootstrap-datetimepicker
//= require jquery-ui.min
//= require jquery.powertip.min
//= require jquery.bsAlerts.min
//= require jquery.minicolors
//= require private_pub
//= require jquery.ui.datepicker
//= require jquery.ui.core
//= require jquery.wysiwyg

//= require highcharts/highcharts
//= require highcharts/highcharts-more

//= require tinymce

//= require_self

/*!
 * jQuery Cookie Plugin v1.3.1
 * https://github.com/carhartl/jquery-cookie
 *
 * Copyright 2013 Klaus Hartl
 * Released under the MIT license
 */
(function (factory) {
	if (typeof define === 'function' && define.amd) {
		// AMD. Register as anonymous module.
		define(['jquery'], factory);
	} else {
		// Browser globals.
		factory(jQuery);
	}
}(function ($) {

	var pluses = /\+/g;

	function raw(s) {
		return s;
	}

	function decoded(s) {
		return decodeURIComponent(s.replace(pluses, ' '));
	}

	function converted(s) {
		if (s.indexOf('"') === 0) {
			// This is a quoted cookie as according to RFC2068, unescape
			s = s.slice(1, -1).replace(/\\"/g, '"').replace(/\\\\/g, '\\');
		}
		try {
			return config.json ? JSON.parse(s) : s;
		} catch(er) {}
	}

	var config = $.cookie = function (key, value, options) {

		// write
		if (value !== undefined) {
			options = $.extend({}, config.defaults, options);

			if (typeof options.expires === 'number') {
				var days = options.expires, t = options.expires = new Date();
				t.setDate(t.getDate() + days);
			}

			value = config.json ? JSON.stringify(value) : String(value);

			return (document.cookie = [
				config.raw ? key : encodeURIComponent(key),
				'=',
				config.raw ? value : encodeURIComponent(value),
				options.expires ? '; expires=' + options.expires.toUTCString() : '', // use expires attribute, max-age is not supported by IE
				options.path    ? '; path=' + options.path : '',
				options.domain  ? '; domain=' + options.domain : '',
				options.secure  ? '; secure' : ''
			].join(''));
		}

		// read
		var decode = config.raw ? raw : decoded;
		var cookies = document.cookie.split('; ');
		var result = key ? undefined : {};
		for (var i = 0, l = cookies.length; i < l; i++) {
			var parts = cookies[i].split('=');
			var name = decode(parts.shift());
			var cookie = decode(parts.join('='));

			if (key && key === name) {
				result = converted(cookie);
				break;
			}

			if (!key) {
				result[name] = converted(cookie);
			}
		}

		return result;
	};

	config.defaults = {};

	$.removeCookie = function (key, options) {
		if ($.cookie(key) !== undefined) {
			// Must not alter options, thus extending a fresh object...
			$.cookie(key, '', $.extend({}, options, { expires: -1 }));
			return true;
		}
		return false;
	};

}));


$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

function sch_slide(){
   $(".input-group .form-control.srch_fld").animate({width:'130px', backgroundColor: '#fff', color: '#000000'}, 200);
   $(".input-group .form-control.srch_fld").blur(function(){
      if($(".input-group .form-control.srch_fld").val() == ""){
       $(this).animate({width:'100px', backgroundColor:'#b4f5e8', color: '#ffffff'}, 400);
     }
   }); 
}  
$('#dealModal').on('show.bs.modal', function (e) {
//if (!data) return e.preventDefault() // stops modal from being shown
$("#extension_for_deal").html("")
});
$('#contactModal').on('show.bs.modal', function (e) {
//display_company_div("hide");
});
$("input").prop('maxlength','100');
$("textarea").prop('maxlength','250');

$("input,textarea").blur(function(){
this.value = jQuery.trim((this.value).replace(/^\s*/g,''))
});
//search field hide show
 var targetInput = $('#search_fld #query');
  $(document).click(function(e) { 
	// Check for left button
	if (e.button == 0) {
		 if($('#search_fld #query').val() == "" && !targetInput.is(document.activeElement) ){$('#search_fld').css("opacity", "0.5");}
	}
});
$('#search_fld').mouseenter(function(){
	$(this).css("opacity", "1");
}).mouseleave(function(){
  if($('#search_fld #query').val() == "" && !targetInput.is(document.activeElement)){$(this).css("opacity", "0.5");}
});
//end search field hide show
//Reset all the data in modal popup BS3
$('#dealModal,#taskModal,#inviteuserModal,#contactModal,#noteModal').on('shown.bs.modal', function () {
//$(this).find('form')[0].reset();
})

//$('a').tooltip()
// placement examples
$('a[rel="tooltip"],i,input:checkbox,div,span').powerTip({smartPlacement: true,fadeInTime: 100,fadeOutTime: 200});
$(".trans-toolbar").click(function(){
	$(".trans-toolbar").toggleClass("trans-toolbar-show");
	 //$('#datetimepicker').datetimepicker({language: 'en',pick12HourFormat: true})
})


$('#search_form').bind('ajax:before', function(evt, data, status, xhr){
  $('#loader').show();
});
function deal_list(deal){
  return "<div> \
    <b><a href='"+deal.result_path+"'>"+deal.title+"</a></b> \
  &nbsp;&nbsp;\
  <b>&bull;</b>&nbsp;&nbsp;\
  Created by <font class='created_by'>"+deal.initiator_name+"</font>&nbsp;&nbsp;\
   <br>\
  <font class='created_by'>Created "+deal.created_at+" &nbsp;&nbsp;</font>\
</div>"
}


function numbersonly(e){
	if (e.shiftKey || e.ctrlKey || e.altKey) {
     e.preventDefault();
     } 
	 else {
       var key = e.keyCode;
       if (!((key == 8) || (key == 9) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
       e.preventDefault();
      }
     }
   }

function onlycharacters(e){
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if( unicode != 8 && unicode != 46){
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 112 && unicode <= 122) ||unicode == 32 ||unicode == 37 ||unicode == 39 ||unicode == 35 ||unicode == 36 ||unicode == 9){
            return true;
        }else{
            return false;
        }
    }else{

       return true;
    }
}

function onlycharacterandnumbers(e){
    var unicode = e.charCode ? e.charCode : e.keyCode;
	
    if( unicode != 8 && unicode != 46){
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) || unicode == 32 ||  (unicode >= 48 && unicode <= 57)){
            return true;
        }else{
            return false;
        }
    }else{
        return true;
    }
}
function onlycharacterandnumberswospace(e){
    var unicode = e.charCode ? e.charCode : e.keyCode;
	
    if( unicode != 8 && unicode != 46){
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) || (unicode >= 48 && unicode <= 57)){
            return true;
        }else{
            return false;
        }
    }else{
        return true;
    }
}
function onlycharacternumberscommadotsquote(e){
    var unicode = e.charCode ? e.charCode : e.keyCode;
	
    if( unicode != 8 && unicode != 46){
        if ((unicode >= 65 && unicode <= 90) || (unicode >= 97 && unicode <= 122) ||unicode == 32 || unicode == 39 || unicode == 44 || unicode == 46  || (unicode >= 48 && unicode <= 57)){
            return true;
        }else{
            return false;
        }
    }else{
        return true;
    }


}
 function floatsonly(e){


	var unicode=e.charCode? e.charCode : e.keyCode
	if (unicode!=8 && unicode!=46){ 
		if (unicode<48||unicode>57) //if not a number
		return false //disable key press
	}
}

function check_float(id,e){
	var float_val = $("#"+id).val().split(".");
	var unicode=e.charCode? e.charCode : e.keyCode;
	if (unicode!=8 && unicode!=46){ 
		if (unicode<48||unicode>57) //if not a number
		return false //disable key press
	}
	if(float_val[1] != undefined){
		if (unicode != 8 && unicode != 46) {
			if (float_val[1].length == 2) {
				return false;
			}
		}
	}
}
function formValidation() {
"use strict";
//alert('form')
    /*----------- BEGIN validationEngine CODE -------------------------*/
    $('#new-contact').validationEngine();
    
    alert($('#new-contact').validationEngine())
    /*----------- END validationEngine CODE -------------------------*/

}

function reset_notification(){
  $("#bell_notification").removeClass("purple");
  $("#notification_image").html("<img alt='Default-icon-bell' src='/assets/default-icon-bell.png'>")
  $("#notification_popup").css("right","11px");
  $("#notification_popup").html("<li class='dropdown-header' style='text-align:center;border-radius: 5px 5px 0 0;padding: 6px;'><i class='icon-warning-sign '></i>&nbsp;No Unread Notifications</li>")
}
function set_required_for_file_descrption(obj){

  //var filelist = document.getElementById('note_attachment').files || [];
    
    //$('#show_file_name').html("");
    //$('#remove_file_ids').val("");
    //for (var i = 0; i < filelist.length; i++) {
    //    
    //    filename = filelist[i].name
    //    $('#show_file_name').append('<div id= "file_'+i+'"><input type="checkbox"  checked="" onchange="removeNoteFileatt('+ i +');" name="file_chk" style="cursor:pointer;margin-right:5px">'+filename+'<br></div>');
    //}
    if($("#prv_pub").length <=0)
    {
    $('#show_file_name').append('<div id="prv_pub"><label class="checkbox-inline" style="padding-left:0;color:#999999">\
                              <input checked="checked" name="note[is_public]" type="radio" value="false">\
                              Private\
                            </label>\
                            <label class="checkbox-inline" style="color:#999999">\
                              <input  name="note[is_public]" type="radio" value="true">\
                              Public\
                            </label></div>');
	}
    //$("#show_file_name").html(str);
    $("#show_file_name").show("slow");
 
}
var vals ="";
function removeNoteFileatt(id)
{
  var checkboxes1 = document.getElementsByName('file_chk');
  
   vals += id+ ",";
   $('#remove_file_ids').val(vals);
   $("#file_"+id).remove();
   
   if(checkboxes1.length == 0)
   {

    
    $("#show_file_name").hide("slow");
    $('#remove_file_ids').val("");
    $("#note_attachment").val("");
   }
	//$("#show_file_name").html("");
	 
	//$("#show_file_name").hide("slow");
}

function selected_dropdown_task_popup(first_name){
  $('#task_assigned_to option').filter(function() { 
    return ($(this).text() == first_name); 
  }).prop('selected', true);
}
function show_cc_bcc(type){
 if (type == "cc"){   
   if($('#bcc_div').is(':visible')){ 
     $('#cc_div').show();$('#cc_bcc_div').show();$('#cc_link').hide();$('#cc_div').removeClass('col-md-12').addClass('col-md-6');$('#bcc_div').show();$('#bcc_div').removeClass('col-md-12').addClass('col-md-6');
   }else{
    $('#cc_div').show();$('#cc_bcc_div').show();$('#cc_link').hide();$('#bcc_div').hide();$('#cc_div').removeClass('col-md-6').addClass('col-md-12');
   }  
     
 }else{   
   if($('#cc_div').is(':visible')){
     $('#cc_bcc_div').show();$('#bcc_link').hide();$('#bcc_div').show();$('#cc_div').hide();$('#cc_div').removeClass('col-md-12').addClass('col-md-6');$('#cc_div').show();$('#bcc_div').removeClass('col-md-12').addClass('col-md-6');
   }
   else{
     $('#cc_bcc_div').show();$('#bcc_link').hide();$('#bcc_div').show();$('#cc_div').hide();$('#bcc_div').removeClass('col-md-6').addClass('col-md-12');
   }
 
 }
}

function hide_cc_bcc(type)
{
  if(type == "cc"){
    $('#cc').val('');
    $('#cc_div').hide();
    $('#cc_link').show();
    if($('#bcc_div').is(':visible')){
      $('#bcc_div').removeClass('col-md-6').addClass('col-md-12');
    }
  }
  else if(type == "bcc"){
    $('#bcc').val('');
    $('#bcc_div').hide();
    $('#bcc_link').show();
    if($('#cc_div').is(':visible')){
      $('#cc_div').removeClass('col-md-6').addClass('col-md-12');
    }
  }
}

$(window).on('load', function () {
$('form input[type="text"].bfh-phone, form input[type="phone"].bfh-phone, span.bfh-phone').each(function () {
var $phone = $(this);
$phone.bfhphone($phone.data());
});
$("#user_time_zone").addClass("col-md-12 form-control");
$("#user_role_id").addClass("pull-right form-control");
$("#user_role_id").css({'width': '130px', 'margin-top': '-8px'})
});
  
//Prefill extension for country according to country
function prefill_extension(obj,extension_id,hidden_id){
 if(obj != ""){
  $.get("/get_extension",{id: obj },function(res){
      if(res != null){
         $("#"+extension_id).html("+"+res.extension);
         $("#"+hidden_id).val("+"+res.extension);
      }
    });
 }else{
    $("#"+extension_id).html("");
 }

}  
  
function checkFile_withtype(obj){
      var flname = $("#"+obj.id).val().split(/\\/).pop();
      var ext = flname.split('.').pop().toLowerCase();
      if (!ext.match('png|gif|jpeg|jpg')) {
        alert("Currently, only photos of .png, .gif, .jpeg and .jpg can be uploaded!");
        $("#"+obj.id).val('')
        return false;
      } 
}   

function chk_edit_dealvalidation(){
	var prb = $("#deal_probability").val();
	if(prb > 100){
	$("#err_prb").html('Probability should be between 0 - 100.')
	$("html, body").animate({ scrollTop: 0 }, 600);
	return false;
	}
}
function chk_validation(type){
    var url = $("#"+type+"_website").val();
    var prb = $("#deal_probability").val();
	var email_chk = $("#"+type+"_email").val();
	var atpos=email_chk.indexOf("@");
    var dotpos=email_chk.lastIndexOf(".");
	
    var pattern1= new RegExp(/^(http:\/\/www\.|https:\/\/www\.)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/);
    //var pattern2= new RegExp(/^(www|http(?:s)?\:\/\/[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*[.][A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*([.][A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*)*)$/);
    if(pattern1.test(url) == false){
    $("#err_msg").html('Invalid Url')
    return false;
    }
    if(prb > 100){
    $("#err_prb").html('Probability should be between 0 - 100.')
    $("html, body").animate({ scrollTop: 0 }, 600);
    return false;
    }
	if (email_chk != '' && (atpos<1 || dotpos<atpos+2 || dotpos+2>=email_chk.length))
  {
   $("#email_err").html('Please enter a valid email address.')
   $("html, body").animate({ scrollTop: 0 }, 600);
  return false;
  }
else
{
  $("#email_err").html('')
}
}
function validate_email(type)
{
var email_id=$("#"+type+"").val();

var atpos=email_id.indexOf("@");
var dotpos=email_id.lastIndexOf(".");
if (email_id != '' && (atpos<1 || dotpos<atpos+2 || dotpos+2>=email_id.length))
  {
   $("#email_err").show();
   $("#email_err").html('Please enter a valid email address.')
   $("#email_err_i").html('Please enter a valid email address.')
   $("#email_err_usr").html('Please enter a valid email address.')
  return false;
  }
  
else
{
  $("#email_err").hide();
  $("#email_err").html('')
  $("#email_err_i").html('')
  $("#email_err_usr").html('')
}
} 
function validate_email_contact()
{
 var chk_con_ty = $("#chk_con_type").val();
 if(chk_con_ty == "individual")
   var email_con=$("#email").val();
 else
   var email_con=$("#company_email").val();
   
var atpos=email_con.indexOf("@");
var dotpos=email_con.lastIndexOf(".");
if (email_con != '' && (atpos<1 || dotpos<atpos+2 || dotpos+2>=email_con.length))
  {
   $("#email_err_con").show();
   $("#email_err_ind").show();
   $("#email_err_con").html('Please enter a valid email address.')
   $("#email_err_ind").html('Please enter a valid email address.')
  return false;
  }
else
{
  $("#email_err_con").hide();
   $("#email_err_ind").hide();
  $("#email_err_con").html('')
  $("#email_err_ind").html('')
}
} 
//Need to be optimize
function validate_send_email()
{
var docDescription = $("#message").val();
if(docDescription != "")
{
 var docDesc1 = docDescription.replace(/(?:&nbsp;|<br>)/g,' ');
 var dd = docDesc1.replace(/^\s+/g, "")

if(dd.length == 0)
{
 $("#email_err_msg").html('Message cannot be blank.')
 return false;
}
else
{
 $("#email_err_msg").html("");
}
}
else
{
  $("#email_err_msg").html('Message cannot be blank.')
}
var email_to=$("#to").val();
var email_cc=$("#cc").val();
var email_bcc=$("#bcc").val();

var atpos=email_to.indexOf("@");
var atpos_cc=email_cc.indexOf("@");
var atpos_bcc=email_bcc.indexOf("@");

var dotpos=email_to.lastIndexOf(".");
var dotpos_cc=email_cc.lastIndexOf(".");
var dotpos_bcc=email_bcc.lastIndexOf(".");

if (email_to != '' && (atpos<1 || dotpos<atpos+2 || dotpos+2>=email_to.length))
  {
   $("#email_err_to").html('Please enter a valid email address.')
  return false;
  }
else
{
  $("#email_err_to").html('')
}

if (email_cc != '' && (atpos_cc<1 || dotpos_cc<atpos_cc+2 || dotpos_cc+2>=email_cc.length))
  {
   $("#email_err_cc").html('Please enter a valid email address.')
  return false;
  }
else
{
  $("#email_err_cc").html('')
}

if (email_bcc != '' && (atpos_bcc<1 || dotpos_bcc<atpos_bcc+2 || dotpos_bcc+2>=email_bcc.length))
  {
   $("#email_err_bcc").html('Please enter a valid email address.')
  return false;
  }
else
{
  $("#email_err_bcc").html('')
}
} 
function reset_email_err_msg()
{
  $("#email_err_bcc").html('');
  $("#email_err_cc").html('');
  $("#email_err_to").html('');
} 

function disable_text(e)
{
 var unicode=e.charCode? e.charCode : e.keyCode;
 if(unicode != 9)
  e.preventDefault();
}

/*$(function(){
    var current_li_id = $(".activ_mnu").attr('id');
    $("#menu-top-nav-menu").on('mouseover','li',function (event) {
    var hover_li_id = event.currentTarget.id;
    $("#"+current_li_id).removeClass('activ_mnu');
      $("#"+hover_li_id).addClass('activ_mnu');
    }).on('mouseout','li',function (event) {
      var hover_li_id = event.currentTarget.id;
      $("#"+hover_li_id).removeClass('activ_mnu');
        $("#"+current_li_id).addClass('activ_mnu');
    });
});*/
function showImageForCrop(obj)
{
	if(checkFile_withtype(obj)==true)
	{
	//alert('coming here');
	
	//$('#crop_loader').show();
	//		var user_id = $("#user_id").val();
	//		$.get("/user_save_tmp_img",{user_id: user_id },function(res){
	//		  if(res != null){
	//			 $("#crop_data").html(res);
	//			 $('#crop_loader').hide();
	//		  }
	//		});
	}
}
var url = window.location.pathname;
$(document).keydown(function(e){
  $('input[type=text], input[type=email], textarea').on("keydown blur", function(e){
    if (e.shiftKey && (e.which == 188 || e.which == 190)) {
      e.preventDefault();
      $('.do_not_allow').remove();
      if(url != '/' || (url == '/' && $("#is_login").val() == 1)){
        $(this).after("<span class='do_not_allow'>Note: HTML tags are not allowed.</span>");
      }
    }
  });
  
  $('input[type=text], input[type=email], textarea').blur(function(){
    var VAL = $(this).val();
    var regex = /<(.|\n)*?>/
    if(VAL.match(regex)){
      $(this).val((VAL.replace(regex, "")));
      if(url != '/' || (url == '/' && $("#is_login").val() == 1)){
        $('.do_not_allow').remove();
        $(this).after("<span class='do_not_allow'>Note: HTML tags are not allowed.</span>");
      }
    }
  });  
});