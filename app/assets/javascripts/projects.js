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
            pledgeBox = this.appendPledgeContainer(container);
            this.appendPledgeDetails(pledgeBox, pledge);
        }.bind(this));
    };
    pledgesButton.appendPledgeContainer = function(container) {
        var $subContainer = $("<div class='row'></div>").appendTo(container);
        return $("<div class='span8 highlight'></div>").appendTo($subContainer);
    }
    pledgesButton.appendPledgeDetails = function(container, pledge) {
        var pledge_time = new Date(pledge['created_at']).toLocaleString();
        return $("<p>$" + pledge['amount'] + " were pledged by " + pledge["user"]["name"] + " on " + pledge_time + "</p>").appendTo(container);
    }
    var messagesButton = new AjaxMenuButton('messages-button', 'messages', 'Messages', 'admin_conversation');
    //Parse response data to display messages
    messagesButton.displayData = function(responseData, container) {
        this.appendNewMessageLink(container);
        $.each(responseData, function(index, message) {
            messageBox = this.appendMessageContainer(container);
            this.appendSenderName(messageBox, message);
            this.appendSubjectLink(messageBox, message);
            this.appendDateTime(messageBox, message);
        }.bind(this));
    }
    messagesButton.appendNewMessageLink = function(container) {
        return container.append("<a href='" + $('#' + this.buttonId).attr('data-new-message-link') + "' data-remote='true'>+ New Message</a>");
    }
    messagesButton.appendMessageContainer = function(container) {
        return $("<div class='row read-highlight'></div>").appendTo(container);
    }
    messagesButton.appendSenderName = function(container, message) {
        return $("<div class='span2'>" + message['sender']['name'] + " </div>").appendTo(container);
    }
    messagesButton.appendSubjectLink = function(container, message) {
        return $("<div class='span6'><a href='/messages/" + message["id"] + "'>" + this.getSubject(message) + "</a></div>").appendTo(container);
    }
    messagesButton.appendDateTime = function(container, message) {
        var messageTime = new Date(message['updated_at']).toLocaleString();
        return $("<div class='span3'>" + messageTime + " </div>").appendTo(container);
    }
    messagesButton.getSubject = function(message) {
        return "[" + message['project']['title'] + "] " + message['subject'];
    }
    var descriptionButton = new MenuButton('description-button', 'description');
});
$(window).load(function(){
  $('#slider').ramblingSlider();
});
