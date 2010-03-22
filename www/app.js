$(function() {
    $.getJSON("app/osp_web/clusterwide?operation=apps",
        function(apps) {
            var app_list = "<ul>";
            $.each(apps,
                   function(index, app_name) {
                       app_list += '<li class="draggable border" id="' + app_name + '">' + app_name + ' Port: <input type="text" style="width: 3em;" id="' + app_name + '-port" /></li>';
                   });
            app_list += "</ul>";
            $("#app_list_loading").remove();
            $("#apps").append(app_list);

            $(".draggable").draggable({
       	        helper: 'clone',
                connectToSortable: ".sortable"
            });
    });

    $.getJSON("app/osp_web/clusterwide?operation=appnode",
	      function(nodes) {
		$.each(nodes,
		       function(node_num, n) {
			 var node_block = "";
			 node_block = '<div id="node_' + node_num + '" class="border node" style="float: left; margin-right: 20px;">' +
				      '  <h4 class="center">' + n.node + '</h4>' +
				      '  <ul class="sortable droppable">';
			 $.each(n.running_apps,
				function(app_num, app) {
				  node_block += '<li class="draggable border" id="app_' + app_num +'">' +
				                  app.name + ' Port: <input type="text" style="width: 3em;" id="app_' + app_num + '_port" value="' + app.port + '"/>' +
				                '<br /><br /><a href="#" id="stop_app_' + app_num + '" class="stop_app">Stop</a>' +
				                '</li>';
				});
			 node_block += '    <li></li>' +
				       '  </ul>' +
				       '</div>';

			 $("#node_loading").remove();
			 $("#nodes").append(node_block);
		       });
		$("#nodes").append('<br style="clear: both;" />');

		$(".droppable").sortable({
		    connectWith: '.droppable',
		    stop: function(event, ui) {
		            if ($(ui.item).children("a").size() == 0) {
		              $(ui.item).append('<br /><br /><a href="#" class="stop_app">Stop</a>');
		            }
		          }
		});
	      });

    $("body").click(function(event) {
	var $target = $(event.target);
        if ($target.is(".stop_app")) {
	    event.preventDefault();
	    $target.parent().remove();
	}
    });
});