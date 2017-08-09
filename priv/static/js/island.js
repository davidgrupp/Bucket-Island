

var resizeAndRotateTransforms = [
	'resize1 3s infinite linear both'
	,'resize1 7s infinite linear both'
	,'rotate1 3s infinite linear both'
	,'rotate1 7s infinite linear both'
	,'resizeAndRotate1 3s infinite linear both'
	,'resizeAndRotate1 7s infinite linear both'];
var moveTransforms = ['move1 3s 1 linear both','move2 3s 1 linear both','move3 3s 1 linear both','move4 3s 1 linear both'];
var tourTransforms = [ 
	 'tour1 10s infinite linear both'
	,'tour2 10s infinite linear both'
	,'tour3 10s infinite linear both'
	,'tour4 10s infinite linear both'
	,'tour5 10s infinite linear both'
	,'tour6 10s infinite linear both'];
var maxImages = 30;
function MakeIsland(){
	var allImgs = jQuery('.main img');
	var imgsToRemove = allImgs.length - maxImages;
	for(var i = 0; i < imgsToRemove; i++){
		jQuery('.main img:nth-child('+Math.floor((Math.random() * allImgs.length))+')').remove();
	}

	var transformsToAdd = ' animation: ';
	
	var doResizeAndRotate = Math.floor((Math.random() * 4)) > 1;
	var doMove = Math.floor((Math.random() * 2)) == 0;
	var doTour = Math.floor((Math.random() * 2)) == 0;
	
	if(doResizeAndRotate){
		transformsToAdd += resizeAndRotateTransforms[Math.floor((Math.random() * resizeAndRotateTransforms.length))] + ',';
	}
	
	if(doMove){
		transformsToAdd += moveTransforms[Math.floor((Math.random() * moveTransforms.length))] + ',';
	}
	else if(doTour){
		transformsToAdd += tourTransforms[Math.floor((Math.random() * tourTransforms.length))] + ',';
	}
	
	transformsToAdd = transformsToAdd.replace(/,+$/, '');
	console.log(transformsToAdd);
	var left = Math.floor((Math.random() * 1500));
	var top = Math.floor((Math.random() * 800));
	jQuery('.main').append("<img class='island' style='left: "+left+"; top: "+top+"; "+transformsToAdd+"' src='"+img64+"'/>");
}

jQuery(function(){
  //setInterval(function(){ MakeIsland(); }, 1000);
});