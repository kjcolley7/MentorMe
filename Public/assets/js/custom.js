var rating = 0;
//localStorage.setItem('logged', 0);
$("#stars").click(function(e){

        var leftSide = $(this).offset().left;
        var rightSide = leftSide + $(this).width()
        var length = rightSide - leftSide;
        var xClick = e.pageX - leftSide;

        var rating = Math.ceil(xClick/length*5);

       if(rating > 5)
           rating = 5;
        if(rating < 0)
            rating = 0;

        console.log(rating);

        var newText = '', i;
        for(i = 0; i < rating; i++)
            newText += '★'
        for(i = i; i < 5; i++)
            newText += '☆'
        $(this).html(newText);
        $.ajax({
          type: 'post',
          url: '/api/v1/rating',
          data: JSON.stringify(rating),
          success: function(results) {
            alert("Rating sent");
          }
        })

        window.location.href = "/";
});

$("#categorySubmit").click(function(e){
    AddCustomTag();
   $('#addOtherModal').modal('hide');
});

function AddCustomTag()
{
   var newCategory = $("#customCategory").val();
   var tagsCol = $("#tags");
   tagsCol.prepend('<button class="btn btn-primary active" type="button" data-toggle="button" aria-pressed="true">'+newCategory+'</button>');
}
