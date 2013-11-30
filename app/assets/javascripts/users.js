//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/
window.onload = function() {
  console.log(document.getElementsByClassName('unread')[0]);
  document.getElementsByClassName('unread')[0].scrollIntoView();
}