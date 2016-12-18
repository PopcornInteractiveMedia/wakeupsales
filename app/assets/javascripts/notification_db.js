var createStatement = "CREATE TABLE IF NOT EXISTS TaskNotification (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, duedate TEXT, tasktype TEXT, created_by TEXT, assigned_to TEXT, deal_id INTEGER, is_complete INTEGER, is_notified INTEGER)";

var createLoginStatement = "CREATE TABLE IF NOT EXISTS is_login (id INTEGER PRIMARY KEY AUTOINCREMENT, is_login INTEGER, is_record_insert INTEGER)";
 
var selectAllStatement = "SELECT * FROM TaskNotification where is_notified = 0";

var selectLoginStatement = "SELECT * FROM is_login";
 
var insertStatement = "INSERT INTO TaskNotification (title, duedate, tasktype, created_by, assigned_to, deal_id, is_complete, is_notified  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

var insertloginStatement = "INSERT INTO is_login (is_login, is_record_insert ) VALUES (?,?)";
 
var updateStatement = "UPDATE TaskNotification SET is_notified = ? WHERE id=?";
 
var deleteStatement = "DELETE FROM TaskNotification WHERE id=?";
 
var dropStatement = "DROP TABLE TaskNotification";

var dropLoginStatement = "DROP TABLE is_login";


var truncateStatement = "TRUNCATE TABLE TaskNotification";
 
var db = openDatabase("TaskReminder", "1.0", "Task Notification Reminder", 200000);  // Open SQLite Database
 
var dataset;
 
var DataType;
 
 function initDatabase()  // Function Call When Page is ready.
{
    try {
 
        if (!window.openDatabase)  // Check browser is supported SQLite or not.
 
        {
 
            alert('Databases are not supported in this browser.');
 
        }
 
        else {
 
            createTable();  // If supported then call Function for create table in SQLite
 
        }
 
    }
 
    catch (e) {
 
        if (e == 2) {
 
            // Version number mismatch. 
 
            console.log("Invalid database version.");
 
        } else {
 
            console.log("Unknown error " + e + ".");
 
        }
 
        return;
 
    }
 
}
 
function createTable()  // Function for Create Table in SQLite.
 
{
 
    db.transaction(function (tx) { tx.executeSql(createStatement, []); });
    db.transaction(function (tx) { tx.executeSql(createLoginStatement, []); });
 
}

function insertLoginRecord(){
	var logv= "1" 
	db.transaction(function (tx) { tx.executeSql(insertloginStatement, [logv,logv]); });
}
 
function insertRecord() // Get value from Input and insert record . Function Call when Save/Submit Button Click..
 
{
		
		//var title = "5th deal/5th task";
		//var duedate = "2014-04-04 18:24:00"; //yy-dd-mm
		//var tasktype = "Followup";
		//var created_by = "Srikant";
		//var assigned_to = "Deepak";
		//var is_complete = "0";
		//var is_notified = "0";
		$.ajax({  type: "get", url: "/get_sqllite_task", dataType: 'json', async: false,
	      beforeSend: function(){
	      },
	      success: function(data){
	      },
	      error: function(data) {
	      },
	      complete: function(datares) {
	      	//alert(JSON.stringify(datares.responseJSON, null, 4));
	      	if(datares.responseJSON.length>0){
		      	$.each(datares.responseJSON, function(i, obj) {
				  //alert(obj.title);
				  db.transaction(function (tx) { tx.executeSql(insertStatement, [obj.title, obj.duedate, obj.tasktype, obj.created_by, obj.assigned_to, obj.deal_id, obj.is_complete, obj.is_notified]); });
				});
		      	check_notification();

	      	}
	       }
	    });	
	    
		
        
        //tx.executeSql(SQL Query Statement,[ Parameters ] , Sucess Result Handler Function, Error Result Handler Function );
}
 
function deleteRecord(id) // Get id of record . Function Call when Delete Button Click..
{
    var iddelete = id.toString();
    db.transaction(function (tx) { tx.executeSql(deleteStatement, [id]); alert("Delete Sucessfully"); });
}
 
function updateRecord(noti,id) // Get id of record . Function Call when Delete Button Click..
 
{
    db.transaction(function (tx) { tx.executeSql(updateStatement, [noti, id]); });
}
 
function dropTable() // Function Call when Drop Button Click.. Talbe will be dropped from database.
{
    db.transaction(function (tx) { tx.executeSql(dropStatement, []); });
    db.transaction(function (tx) { tx.executeSql(dropLoginStatement, []); });
    //initDatabase();
}
 

function onError(tx, error) // Function for Hendeling Error...
{
    //alert(error.message);
}
 
function get_login_info(){
	db.transaction(function (tx) {
	        tx.executeSql(selectLoginStatement, [], function (tx, result) {
                $('#hdn_sqllite').val("1");
                
	           },
            function(tx, error) {
			    dropTable();
			    initDatabase();
			    insertRecord();
			    insertLoginRecord(1,1);            	
            	});
	            		
	});
}

function showRecords() // Function For Retrive data from Database Display records as list
{
   
    db.transaction(function (tx) {
 
        tx.executeSql(selectAllStatement, [], function (tx, result) {

           //alert('fire');
            dataset = result.rows;
            k=0;

            for (var i = 0, item = null; i < dataset.length; i++) {


                item = dataset.item(i);
				var dateObj = new Date(item['duedate']);
				var curdateobj = new Date();
				var dtobj =  new Date();
				curdateobj.setMinutes(curdateobj.getMinutes() + 10);
				if(curdateobj > dateObj )
				{
				  //curdateobj.setMinutes(dateObj.getMinutes() - 10);
				  if(dateObj > dtobj ){
					  if ( $('#hdn_sqllite').val() == "1")
					  {
					    notify(item['title'], (item['tasktype'] + " @ " + dateObj.getHours() + ":" + dateObj.getMinutes() ), item['deal_id']  );
					   }
					   }

					 updateRecord(1,item['id']);
					 k++;


				 
				}
              }
            if($('#hdn_sqllite').val() == "0" && (k>0))
			{
				notify( k + " overdue task(s) fo the day." , "www.wakeupsales.com" , ""  );
				$('#hdn_sqllite').val("1")
			}  
 
        });
 
    });
 
}
 
 
//chrome desktop notification function
function notify(title, desc, dealid) {
	if( window.webkitNotifications) {
		var havePermission = window.webkitNotifications.checkPermission();
		if (havePermission == 0) {
			// 0 is PERMISSION_ALLOWED
			//var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
			var url = window.location.origin;
			if( $('#hdn_sqllite').val() == 0)
			{
				linkurl =  url +'/tasks?type=today'
			}
			else
			{
				linkurl =  url +'/leads/'+dealid
			}
			var notification = window.webkitNotifications.createNotification(
				 url + '/assets/task-icon-larger.png',
				title,
				desc
			);
			notification.onclick = function () {
				try{
					window.focus();
					window.location =linkurl;
					notification.cancel();
				} catch(e){}
			};
			//setTimeout(function(){
			//	try{
			//		notification.cancel();
			//	} catch(e){}
			//}, 10000);
			notification.show();
		} else {
			window.webkitNotifications.requestPermission();
			
		}
	}
}
function allowChromeDskNotify(){
	if (window.webkitNotifications && window.webkitNotifications.checkPermission()!=0) {
		window.webkitNotifications.requestPermission();
	}
}
//end chrome desktop notification function

 
function check_notification()
{
 showRecords();
}

$(document).ready(function () // Call function when page is ready for load..
{
    $('body').click(function(){ allowChromeDskNotify()});
	

	
	if($('#is_login').val() == 1)
	{
		get_login_info();

	}
	else
	{
	 dropTable();	
	}
	setInterval(function(){check_notification();}, 30000);
	
    //$("body").fadeIn(2000); // Fede In Effect when Page Load..
    
	//dropTable();
    //initDatabase();
	//insertRecord();
	
	
		
	//check_notification();

    //$("#submitButton").click(insertRecord);  // Register Event Listener when button click.
 
    //$("#btnUpdate").click(updateRecord);
 
    //$("#btnReset").click(resetForm);
 
    //$("#btnDrop").click(dropTable);
});
 
