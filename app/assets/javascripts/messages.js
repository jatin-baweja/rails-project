window.onload = function() {
  // #FIXME_AB: What if console is undefined. It happens in IE. Read: http://digitalize.ca/2010/04/javascript-tip-save-me-from-console-log-errors/ 
  // #FIXED: Removed console log
  // Move to unread message in message chain.
  document.getElementsByClassName('unread')[0].scrollIntoView();
}
