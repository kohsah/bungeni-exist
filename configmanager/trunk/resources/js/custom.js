$(document).ready(function(){
    if(window.location.hash) {
        //get the index from URL hash
        tabSelect = document.location.hash.substr(1,document.location.hash.length);
        $('#tabs li#tabfields').trigger('click');
    }  
    /*
    $('#submitname').bind('click', function(e) {
        e.preventDefault();
        alert("aasas");
        //$("#f-transition-popup").submit();
    });             
    
     $('.popup').on('click', function(e) {
        // Prevents the default action to be triggered. 
        e.preventDefault();
        var href = $(this).attr('href');
        
        // Triggering bPopup when click event is fired
        $('#popup').bPopup({
            contentContainer:'.popupcontent',
            loadUrl: 'transition-add-popup.html?doc=question&node=submitted&attr=29',            
            modalClose: true,
            opacity: 0.2,
            positionStyle: 'fixed' //'fixed' or 'absolute'
        });
     });
    */
    
    //  When user clicks on tab, this code will be executed
    $("#tabs li").click(function() {
        //  First remove class "active" from currently active tab
        $("#tabs li").removeClass('active');
 
        //  Now add class "active" to the selected/clicked tab
        $(this).addClass("active");
 
        //  Hide all tab content
        $(".tab_content").hide();
 
        //  Here we get the href value of the selected tab
        var selected_tab = $(this).find("a").attr("href");
 
        //  Show the selected tab content
        $(selected_tab).fadeIn();
 
        //  At the end, we add return false so that the click on the link is not executed
        return false;
    });
    
    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
    $(".up, .down").click(function(){
        var row = $(this).parents("li:first");
        var href = $(this).attr('href');
        if ($(this).is(".up")) {
            $("ul.ulfields li:first .up").show();
            $.get(href,function(data,status) {
                if (status == "success")
                    row.insertBefore(row.prev());
                    row.find(".down").show();
                    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
            });        
            
        } else {        
            $.get(href,function(data,status){             
                if (status == "success") {                
                    row.insertAfter(row.next());   
                    row.find(".up").show();
                    $("ul.ulfields li:first .up,ul.ulfields li:last .down").hide();
                }
            });
        }
        return false;
    });  
    
    //$(".delete").click(function() {
    $(".delete").live('click', function() {
        var href = $(this).attr('href');
        var li = $(this).closest('li');          

        if ($(this).is(".delete")) {   
            if (confirm('Are you sure to delete this field?')) {
                $.ajax({
                    type: "DELETE",
                    url: href,
                    data: "nothing",
                    success: function(data) {                      
                        li.fadeOut('slow', function() { li.remove(); });
                    }
                });        
            }        
        }  
        
        return false;
        
    });        
    
    /*$(".popup").click(function() {
        var href = $(this).attr('href');
        
        $('.').bPopup({
            contentContainer:'.content',
            loadUrl: 'http://localhost:8088/exist/apps/configmanager/views/edit-transition.xql?doc=question&node=submitted&attr=29'
        });
            
        $.ajax({
            type: "GET",
            url: 'http://localhost:8088/exist/apps/configmanager/views/edit-transition.xql?doc=question&node=submitted&attr=29',
            data: "nothing",
            success: function(data){
                //$(row).remove();
            }
        });        

        return false;
        
    }); */   
    
    /*$(".nodeMove a").click (function () {
      $.ajax({
        type: "POST", // or GET
        url: $(this).getAttr('href'),
        data: "nothing",
        success: function(data){
         $("#someElement").doSomething().
        }
      });
      return false; // stop the browser following the link
    }; */   
});