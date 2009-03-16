// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

document.observe("dom:loaded", function(){
	var keyword = window.location.href.match(/^http.*?\#(.*)/);
	if(keyword != null){
		$('query').value = keyword[1].gsub(/\+/, ' ');
		new Ajax.Request('/query', {
			asynchronous:true, 
			evalScripts:true, 
			onLoading:function(request){
				document.fire('search:start');
			},
			onComplete:function(request){
				document.fire('search:done');
			}, 
			parameters:Form.serialize(this)
		}); 
}
});

document.observe('search:start', function(){
	if($('ajax-load').visible()){document.fire("search:done"); return;}
	$('results').hide();
    $('ajax-load').show();
  $('search-button').disable();
  $('search-button').value='Searching';
	document.title = "'" + $('query').value + "' - DJPatter Search Engine";
   var current_location = window.location.href.gsub(/#.*/, "");
   var keywords = $F('query').gsub(/\s/, "+");
   window.location = current_location + "#" + escape(keywords);
});

document.observe('search:done', function(){
	if(!$('ajax-load').visible()){document.fire("search:start"); return;}
	$('results').appear();
	$('ajax-load').hide();
	$('search-button').enable();
	$('search-button').value='Search';
});
