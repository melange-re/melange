// Generated by Melange
'use strict';


function x(url) {
  if (!url) {
    return "start";
  }
  switch (url.hd) {
    case "login" :
      if (url.tl) {
        return "start";
      } else {
        return "login";
      }
    case "start" :
      return "start";
    default:
      return "start";
  }
}

module.exports = {
  x,
}
/* No side effect */
