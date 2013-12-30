window.onload = function() {
  // #FIXME_AB: What if console is undefined. It happens in IE. Read: http://digitalize.ca/2010/04/javascript-tip-save-me-from-console-log-errors/ 
  console.log(document.getElementsByClassName('unread')[0]);
  document.getElementsByClassName('unread')[0].scrollIntoView();
}
