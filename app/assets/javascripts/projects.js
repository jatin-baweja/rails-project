// #FIXME_AB: Can we follow object oriented concepts here too. 
// #FIXED: Object-Oriented approach used
// #FIXME_AB: Can we also add detailed comment. It will help us to understand the working of JS code.  
// #FIXED: Added comments
function MenuButton(buttonId, containerId) {
  var that = this;
  this.buttonId = buttonId;
  this.containerId = containerId;
  $('#' + this.buttonId).on('click', function() {
    var $mainContainer = $('#project-main');
    var $subContainer = $mainContainer.children('#' + containerId);
    //Hide siblings and show specific subcontainer
    $mainContainer.children().hide();
    $subContainer.show();
  });
}
function AjaxMenuButton(buttonId, containerId, heading, appendPath) {
  var that = this;
  this.buttonId = buttonId;
  this.containerId = containerId;
  $('#' + this.buttonId).on('click', function() {
    $.ajax({
      url: window.location.href + "/" + appendPath,
      dataType: "json",
      success: function(responseData, returnStatus, xhr) {
        var $mainContainer = $('#project-main');
        var $subContainer = $mainContainer.children('#' + containerId);
        // Create sub-container if it does not exist already
        if ($subContainer.length == 0) {
          $subContainer = $("<div id='" + containerId + "' class='container-fluid'></div>").appendTo($mainContainer);
        }
        //Hide siblings and clear container content
        $mainContainer.children().hide();
        $subContainer.html("");
        //Add heading and show container
        $subContainer.append($('<h3>' + heading + '</h3>'));
        $subContainer.show();
        //Parse response data from ajax
        that.displayData(responseData, $subContainer);
      },
      error: function(responseData, returnStatus, xhr) {
        alert('Server gave the following response:\n' + responseData.status + ' : ' + responseData.statusText);
      }
    });
  });
}
$(document).ready(function() {
  var pledgesButton = new AjaxMenuButton('pledges-button', 'pledges', 'Pledges', 'backers');
  //Parse response data to display pledges
  pledgesButton.displayData = function(responseData, container) {
    $.each(responseData, function(index, pledge) {
      var pledge_time = new Date(pledge['created_at']).toLocaleString();
      container.append("<div class='row'><div class='span8 highlight'><p>$" + pledge['amount'] + " were pledged by " + pledge["user"]["name"] + " on " + pledge_time + "</p></div></div>");
    });
  };
  var messagesButton = new AjaxMenuButton('messages-button', 'messages', 'Messages', 'admin_conversation');
  //Parse response data to display messages
  messagesButton.displayData = function(responseData, container) {
    container.append("<a href='" + window.location.href + "/new_message' data-remote='true'>+ New Message</a>")
    $.each(responseData, function(index, message) {
      var message_time = new Date(message['updated_at']).toLocaleString();
      container.append("<div class='row read-highlight'><div class='span2'>" + message['sender']['name'] + " </div><div class='span6'><a href='/messages/" + message["id"] + "'>[" + message['project']['title'] + "] " + message['subject'] + "</a></div><div class='span3'>" + message_time + " </div></div>");
    });
  }
  var descriptionButton = new MenuButton('description-button', 'description')
});
