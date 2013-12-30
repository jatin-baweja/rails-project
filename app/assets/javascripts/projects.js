// #FIXME_AB: Can we follow object oriented concepts here too. 
// #FIXME_AB: Can we also add detailed comment. It will help us to understand the working of JS code.  
$(document).ready(function() {
  $('#pledges-button').on('click', function() {
    $.ajax({
      url: window.location.href + "/backers",
      dataType: "json",
      success: function(responseData, returnStatus, xhr) {
        var $mainContainer = $('#project-main');
        var $pledgesContainer = $mainContainer.children('#pledges');
        var $pledgesList = $pledgesContainer.children('#backers');
        if ($pledgesList.length == 0) {
          $pledgesContainer = $("<div id='pledges' class='container-fluid'></div>").appendTo($mainContainer);
          $pledgesContainer.append($('<h3>Pledges</h3>'));
          $pledgesList = $("<div id='backers'></div>").appendTo($pledgesContainer);
        }
        $mainContainer.children().not($pledgesContainer).hide();
        $pledgesList.html("");
        $pledgesContainer.show();
        $.each(responseData, function(index, pledge) {
          var pledge_time = new Date(pledge['created_at']).toLocaleString();
          $pledgesList.append("<div class='row'><div class='span8 highlight'><p>$" + pledge['amount'] + " were pledged by " + pledge["user"]["name"] + " on " + pledge_time + "</p></div></div>");
        });
      }
    })
  });

  $('#description-button').on('click', function() {
    var $mainContainer = $('#project-main');
    var $descriptionContainer = $mainContainer.children("#description");
    $mainContainer.children().not($descriptionContainer).hide();
    $descriptionContainer.show();
  });

  $('#messages-button').on('click', function() {
    $.ajax({
      url: window.location.href + "/admin_conversation",
      dataType: "json",
      success: function(responseData, returnStatus, xhr) {
        var $mainContainer = $('#project-main');
        var $messagesContainer = $mainContainer.children('#messages');
        if ($messagesContainer.length == 0) {
          $messagesContainer = $("<div id='messages' class='container-fluid'></div>").appendTo($mainContainer);
        }
        $mainContainer.children().not($messagesContainer).hide();
        $messagesContainer.html("<h3>Messages</h3><div class='row'><a href='" + window.location.href + "/new_message' data-remote='true'>+New Message</a></div>");
        $messagesContainer.show();
        $.each(responseData, function(index, message) {
          function isUnread(element) {
            return element["unread"] == true;
          }
          var message_time = new Date(message['updated_at']).toLocaleString();
          $messagesContainer.append("<div class='row read-highlight'><div class='span2'>" + message['from_user']['name'] + " </div><div class='span6'><a href='/messages/" + message["id"] + "'>[" + message['project']['title'] + "] " + message['subject'] + "</a></div><div class='span3'>" + message_time + " </div></div>");
        });
      }
    })
  });

});
