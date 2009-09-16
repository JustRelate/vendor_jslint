// rhino.js
// 2009-06-04
/*
Copyright (c) 2002 Douglas Crockford  (www.JSLint.com) Rhino Edition
*/

// This is the Rhino companion to fulljslint.js.

/*extern JSLINT */
/*jslint rhino: true*/

(function (a) {
    if (a.length < 2) {
        print("Usage: rhino.js config_file.js file1.js [file2.js]");
        quit(1);
    }
    var config = readFile(a[0]);
    if (!config) {
        print("jslint: Couldn't open file '" + a[0] + "'.");
        quit(1);
    }
    config = eval('(' + config + ')');
    a.shift();
    for(index in a) {
      var input = readFile(a[index]);
      if (!input) {
          print("jslint: Couldn't open file '" + a[index] + "'.");
      }
      if (!JSLINT(input, config)) {
          for (var i = 0; i < JSLINT.errors.length; i += 1) {
              var e = JSLINT.errors[i];
              if (e) {
                  print('Lint at ' + a[index] + ":" + (e.line + 1) + ' character ' +
                          (e.character + 1) + ': ' + e.reason);
                  print((e.evidence || '').
                          replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"));
                  print('');
              }
          }
      }
    }
}(arguments));
