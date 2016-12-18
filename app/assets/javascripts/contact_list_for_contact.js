/* [ ---- contact list ---- ] */

    $(document).ready(function() {
        //* contact list
          contact_list.basic();
          contact_list.scroll_to();
        
        
    });

    //* contact list
    contact_list = {
        basic: function() {
            if($('#list_basic').length) {
                $('#list_basic').stickySectionHeaders({
                    stickyClass     : 'sticky_header',
                    headlineSelector: 'h4'
                });
            }
        },
        scroll_to: function() {
        	if($('#list').length) {
                
                // init list
                $('#list_scrollTo').stickySectionHeaders({
                    stickyClass     : 'sticky_header',
                    headlineSelector: 'h4'
                });
                
                // generate the list of buttons for the scrollto links
                $('#list_scrollTo li').find('h4').each(function(i){
                    $(this).css({color:"white",width:"1208px"});
                });
                var existingletters = [];
                var firstnames=[];

                //alert(firstchars);
                var firstchars=$("#firstchars").val();
                
                if(typeof(firstchars)!== "undefined")
                {
                	existingletters=firstchars.split(",");
                	
                }
                else
                {
                	$('.list-username').find('a').each(function(obj){
                  		existingletters.push($(this).html().toString()[0].toUpperCase().charCodeAt(0));
                  
                	});
                }
                
                var first = "A", last = "Z";
                var j = first.charCodeAt(0)-65;
                var letters = /^[A-Z,]+$/;
                var fchar = "-";
                str1= "<div class='panel panel-default' id='head-'><div class='panel-heading' data-parent='#accordion' onclick=\"get_contact_per_alphabet('"+fchar+"')\" data-toggle='collapse' href='#collapse-' style='cursor:pointer'>";
                str1+= "<h4 class='panel-title'><div class='fl box_ac'>#</div></h4></div>";
                str1+= "<div class='panel-collapse collapse' id='collapse-' style='height: auto;'>";
                str1+="<div class='jQ-list jQ-list-scroll ' id='list_scrollTo' style='height: 200px;'>";
                str1+= "</div></div></div>";
				 //$("#list_buttons").append('<span class="grey" data-header="*" onclick=\'get_contact_per_alphabet("*")\'>All</span>');
									
                if(letters.test(firstchars) == false)
                {	//$("#list_buttons").append('<span class="grey" data-header="*" onclick=\'get_contact_per_alphabet("-")\'>#</span>');
                    $("#list_buttons").append(str1);
				}
				  for(var i = first.charCodeAt(0); i <= last.charCodeAt(0); i++) {
				    
				    if($.inArray(String.fromCharCode(i), existingletters) != -1)
				    {	
						str= "<div class='panel panel-default' id='head"+ ( eval('String.fromCharCode(' + i + ')')) +"'><div class='panel-heading'    data-parent='#accordion' onclick='get_contact_per_alphabet(" + i + ")' data-toggle='collapse' href='#collapse"+ i +"' style='cursor:pointer'>";
		                str+= "<h4 class='panel-title'><div class='fl box_ac'>"+( eval('String.fromCharCode(' + i + ')'))+"</div></h4></div>";
		                str+= "<div class='panel-collapse collapse'  id='collapse"+ i +"' style='height: auto;'>";
		                str+="<div class='jQ-list jQ-list-scroll ' id='list_scrollTo' style='height: 200px;'>";
		                str+= "</div></div></div>";
    	
				    	//$("#list_buttons").append(str);'<span class="grey" data-header="'+j+'" onclick="get_contact_per_alphabet(' + i + ')">'+( eval('String.fromCharCode(' + i + ')'))+'</span>');
				    	$("#list_buttons").append(str);
				    	j++;
				    }
				    else
				    {
				    	str2= "<div class='panel panel-default' id='head"+ ( eval('String.fromCharCode(' + i + ')')) +"'><div class='panel-heading'   data-parent='#accordion' data-toggle='collapse' href='#collapse"+ i +"' style='cursor:default'>";
		                str2+= "<h4 class='panel-title'><div class='fl box_ac'style='color:#fff;background:#ccc'>"+( eval('String.fromCharCode(' + i + ')'))+"</div></h4></div>";
		                str2+= "<div class='panel-collapse collapse' id='collapse"+ i +"' style='height: auto;'>";
		                str2+= "</div></div>";
						
				    	//$("#list_buttons").append('<span style="color:#aeaeae" data-header="'+j+'">'+( eval('String.fromCharCode(' + i + ')'))+'</span>');
				    	$("#list_buttons").append(str2);
				    }
				  }
                     
                // scroll to list element on button click
                $('#list_buttons span.grey').on('click',function(){
                    $('#list_scrollTo > ul').stop().animate( {scrollTop: $('#list_scrollTo > ul > li').eq($(this).data('header')).position().top + $('#list_scrollTo ul').scrollTop() },1000,'easeOutCubic' );
                });
                
            }
        }
    };
