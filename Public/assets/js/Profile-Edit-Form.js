(function(){
    function readURL(input) {

        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('.avatar-bg').css({
                    'background':'url('+e.target.result+')',
                    'background-size':'cover',
                    'background-position': '50% 50%'
                });
            };

            reader.readAsDataURL(input.files[0]);
        }
    }

    $("input.form-control[name=avatar-file]").change(function(){
        readURL(this);
    });
})()