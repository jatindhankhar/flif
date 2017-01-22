$(document).ready(function() {
    $('.custom-control-input').change(function(el) {
        if ($('.custom-control-input:checked').length) {
            $('#send_fab').removeClass('disabled');
            console.log("multiple Items");
            var target = el.target;
            console.log($(target).parent().parent().siblings("img").attr("src"));

        } else {
            $('#send_fab').addClass('disabled');
        }
    });

    $("#send_fab").click(function(e) {
        var urls = getUrls();
        var userId = $('#userID').val();
        var chatId = $('#chatId').val();
        var payload = {gif_list: urls, user_id: userId, chat_id: chatId }
        console.log(JSON.stringify(payload));
         $.ajax({
            url: '/send',
            type: 'POST',
            data : JSON.stringify({data: payload}),
            success: function(json) {
                alert("Sweet, It's done :)");
            },
           error: function() {
		alert("There was some error :(");
           }
        });
    });

});

function getUrls() {
    var res = []
    $('.custom-control-input:checkbox:checked').map(
        function() {
             var url = $(this).parent().parent().siblings("img").attr("src");
             console.log(url);
             res.push(url)
        }
    );
    return res;
}
