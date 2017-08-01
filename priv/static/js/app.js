var app = function(){
    self = this;
    self.socket = new exports.Socket("/socket");
    self.socket.connect();
    //var $status    = $("#status");
    var $messages  = $("#messages");
    var $input     = $("#message-input");
    var $username  = $("#username");
    var $totalClicks = $(".total-clicks");
    var $main = $("main");
    self.clickTotals = {total_clicks: 0};

    var sanitize = function(html){ return $("<div/>").text(html).html(); }

    self.socket.onOpen(function( ev ) { console.log("OPEN", ev); } );
    self.socket.onError( function( ev ) { console.log("ERROR", ev); } );
    self.socket.onClose( function( e ) {  console.log("CLOSE", e); } );

    self.chan = self.socket.channel("fill:lobby", {})
    self.chan.join().receive("ignore", function() { console.log("auth error"); })
                .receive("ok", function() { console.log("join ok"); });
    self.chan.onError(function( e ) {  console.log("something went wrong", e); });
    self.chan.onClose(function( e ) {  console.log("channel closed", e); });

    $main.click(function(){
        console.log("main click chan push new:click");
        self.clickTotals.total_clicks++;
        $totalClicks.text(self.clickTotals.total_clicks);
        self.chan.push("new:click", {"user": "dwg", "hash": "123abc_hash_asdf", "next_click_hash": "987abc_hash_qwer"});
    });

    self.chan.on("new:msg", function( msg ) {
       console.log("chan on new:msg", msg);
        // $messages.append(messageTemplate(msg));
        //scrollTo(0, document.body.scrollHeight);
    });

    self.chan.on("update:total_clicks", function( msg ) {
       console.log("chan on update:total_clicks", msg.body.total_clicks);
       if(msg.body.total_clicks > self.clickTotals.total_clicks)
            self.clickTotals = msg.body;
       $totalClicks.text(self.clickTotals.total_clicks);
    });

    self.chan.on("user:entered", function( msg ) {
        console.log("chan on user:entered", msg.user);
        //var username = sanitize(msg.user || "anonymous")
        //$messages.append(`<br/><i>[${username} entered]</i>`)
    });
    
}
var a = new app();