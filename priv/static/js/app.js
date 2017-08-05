var app = function(){
    self = this;
    self.socket = new exports.Socket("/socket");
    self.socket.connect();
    //var $status    = $("#status");
    var $messages  = $("#messages");
    var $input     = $("#message-input");
    var $username  = $("#username");
    self.clickTotals = {total_clicks: 0, total_bucket_island: 0, total_other_island: 0, total_swamp: 0, total_forest: 0, total_plains: 0, total_mountain: 0};

    var sanitize = function(html){ return $("<div/>").text(html).html(); }

    self.socket.onOpen(function( ev ) { console.log("OPEN", ev); } );
    self.socket.onError( function( ev ) { console.log("ERROR", ev); } );
    self.socket.onClose( function( e ) {  console.log("CLOSE", e); } );

    self.chan = self.socket.channel("fill:lobby", {})
    self.chan.join().receive("ignore", function() { console.log("auth error"); })
                .receive("ok", function() { console.log("join ok"); });
    self.chan.onError(function( e ) {  console.log("something went wrong", e); });
    self.chan.onClose(function( e ) {  console.log("channel closed", e); });

    $(".land").click(function(elm){
        //var landType = this.attributes 
        console.log("main click chan push new:click");
        var clickType = "bucket_island";
        var classes = $(this).attr('class').split(/\s+/);
        $.each(classes, function(index, item) {
            if (item === 'bucket_island') {
                self.clickTotals.total_bucket_island++;
            }
            else if (item === 'other_island') {
                self.clickTotals.total_other_island++;
                clickType = "other_island";
            }
            else if (item === 'mountain') {
                self.clickTotals.total_mountain++;
                clickType = "mountain";
            }
            else if (item === 'swamp') {
                self.clickTotals.total_swamp++;
                clickType = "swamp";
            }
            else if (item === 'plains') {
                self.clickTotals.total_plains++;
                clickType = "plains";
            }
            else if (item === 'forest') {
                self.clickTotals.total_forest++;
                clickType = "forest";
            }
        });

        self.chan.push("new:click", {"user": "dwg", "click_type": clickType, "hash": "123abc_hash_asdf", "next_click_hash": "987abc_hash_qwer"});
        self.clickTotals.total_clicks++;
        self.updateTotals();
    });

    self.chan.on("new:msg", function( msg ) {
       console.log("chan on new:msg", msg);
        // $messages.append(messageTemplate(msg));
        //scrollTo(0, document.body.scrollHeight);
    });

    self.chan.on("update:total_clicks", function( msg ) {
       console.log("chan on update:total_clicks", msg.body.total_clicks);
       if(msg.body.total_clicks >= self.clickTotals.total_clicks)
            self.clickTotals = msg.body;
        
        self.updateTotals();
    });

    self.chan.on("user:entered", function( msg ) {
        console.log("chan on user:entered", msg.user);
        //var username = sanitize(msg.user || "anonymous")
        //$messages.append(`<br/><i>[${username} entered]</i>`)
    });


    self.updateTotals = function(){
       $(".total_clicks .total-clicks").text("Total: "+ self.clickTotals.total_clicks);
       self.updateClicks('bucket_island', self.clickTotals.total_bucket_island);
       self.updateClicks('other_island', self.clickTotals.total_other_island);
       self.updateClicks('mountain', self.clickTotals.total_mountain);
       self.updateClicks('swamp', self.clickTotals.total_swamp);
       self.updateClicks('plains', self.clickTotals.total_plains);
       self.updateClicks('forest', self.clickTotals.total_forest);
    }

    self.updateClicks = function(clickType, total){
        var level = Math.ceil(Math.log10(total));
        $(".total_"+clickType+" .level").text("Level: "+ level);
        $(".total_"+clickType+" .total").text("Total: "+ total);
        var maxLevelProgress = Math.pow(10, Math.ceil(Math.log10(total)));
        $('.'+clickType+'-level-progress').css('width', (100*total/maxLevelProgress)+'%');
    }
    
}
var a = new app();