chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
    console.log("hihihihihi")
    console.log(sender.tab ?
                "from a content script:" + sender.tab.url :
                "from the extension");
    console.log(request.greeting)
    if (request.greeting == "hello")
      sendResponse({cookie: window.document.cookie});
  });
