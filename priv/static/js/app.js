var app = function(){
    self = this;
    self.socket = new exports.Socket("/socket");
    self.socket.connect();
    //var $status    = $("#status");
    var $messages  = $("#messages");
    var $input     = $("#message-input");
    var $username  = $("#username");
    self.clickTotals = {"total_clicks": 0, "total_bucket_island": 0, "total_other_island": 0, "total_swamp": 0, "total_forest": 0, "total_plains": 0, "total_mountain": 0};
    self.teamTotals = { "total": 0, "bucket_island": 0, "other_island": 0, "swamp": 0, "forest": 0, "plains": 0, "mountain": 0};
    self.team = null;

    var sanitize = function(html){ return $("<div/>").text(html).html(); }

    self.socket.onOpen(function( ev ) { console.log("OPEN", ev); } );
    self.socket.onError( function( ev ) { console.log("ERROR", ev); } );
    self.socket.onClose( function( e ) {  console.log("CLOSE", e); } );

    self.chan = self.socket.channel("fill:lobby", {})
    self.chan.join().receive("ignore", function() { console.log("auth error"); })
                .receive("ok", function() { console.log("join ok"); });
    self.chan.onError(function( e ) {  console.log("something went wrong", e); });
    self.chan.onClose(function( e ) {  console.log("channel closed", e); });

    $(".land").click(function(){
        $('.initial-selection-main').hide();;
        $(".land-lrg").hide();
        var classes = $(this).attr('class').split(/\s+/);
        var clickType = classes[1];
        $("."+clickType).show();
        --self.teamTotals[self.team];
        ++self.teamTotals[clickType];
        if(self.team == null) self.teamTotals.total++;
        self.team = clickType;
        self.chan.push("new:jointeam", {"team": clickType});
        self.updateTeams();
    });

    $(".land-lrg").click(function(elm){
        var classes = $(this).attr('class').split(/\s+/);
        var clickType = classes[1];
        ++self.clickTotals["total_"+clickType];
        ++self.clickTotals.total_clicks;
        self.chan.push("new:click", {});
        self.updateTotals();
    });

    self.chan.on("new:msg", function( msg ) {
       console.log("chan on new:msg", msg);
        // $messages.append(messageTemplate(msg));
        //scrollTo(0, document.body.scrollHeight);
    });

    self.chan.on("update:total_clicks", function( msg ) {
       //console.log("chan on update:total_clicks", msg.body.total_clicks);
       if(msg.body.total_clicks >= self.clickTotals.total_clicks)
            self.clickTotals = msg.body;
        self.updateTeams();
    });

    self.chan.on("update:team_counts", function( msg ) {
       //console.log("chan on update:team_counts", msg.body);
       self.teamTotals = msg.body;
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

    self.updateTeams = function(){
       $(".total_clicks .total-players").text("Total: "+ self.teamTotals.total);
       self.updateTeam('bucket_island', self.teamTotals.bucket_island);
       self.updateTeam('other_island', self.teamTotals.other_island);
       self.updateTeam('mountain', self.teamTotals.mountain);
       self.updateTeam('swamp', self.teamTotals.swamp);
       self.updateTeam('plains', self.teamTotals.plains);
       self.updateTeam('forest', self.teamTotals.forest);
    }

    self.updateTeam = function(clickType, total){
        $(".team-"+clickType+" .team-players-count").text(total);
    }
    
}
var a = new app();